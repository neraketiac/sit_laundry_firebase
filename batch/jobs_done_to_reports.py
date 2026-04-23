import json
import os

import firebase_admin
from firebase_admin import credentials, firestore


SOURCE_SECRET = "FIREBASE_SOURCE_SERVICE_ACCOUNT"
REPORTS_SECRET = "FIREBASE_REPORTS_SERVICE_ACCOUNT"
LOYALTY_SECRET = "FIREBASE_LOYALTY_SERVICE_ACCOUNT"

JOBS_DONE = "Jobs_done"
JOBS_COMPLETED = "Jobs_completed"
SUPPLIES_HIST = "SuppliesHist"
ITEMS_HIST = "ItemsHist"
EMPLOYEE_HIST = "EmployeeHist"
SYNC_DELETE_QUEUE = "sync_delete_queue"
SYNC_TO_DB2_FIELD = "Z00_IsSyncToDB2"
SYNC_STATE_COLLECTION = "batch_sync_state"
LOG_DATE_FIELD = "LogDate"


def init_db(secret_name: str, app_name: str):
    raw = os.environ.get(secret_name)
    if not raw:
        raise RuntimeError(f"Missing environment variable: {secret_name}")

    service_account = json.loads(raw)
    cred = credentials.Certificate(service_account)
    app = firebase_admin.initialize_app(cred, name=app_name)
    return firestore.client(app)


def normalize_payload(data, source_collection, doc_id):
    payload = dict(data or {})
    payload["_source_doc_id"] = doc_id
    payload["_source_collection"] = source_collection
    payload[SYNC_TO_DB2_FIELD] = True
    return payload


def state_ref(source_db, state_key):
    return source_db.collection(SYNC_STATE_COLLECTION).document(state_key)


def sync_pending_collection(source_db, target_dbs, collection_name):
    updated = 0

    docs = source_db.collection(collection_name).where(
        SYNC_TO_DB2_FIELD, "==", False
    ).stream()

    for doc in docs:
        payload = normalize_payload(doc.to_dict(), collection_name, doc.id)
        for target_name, target_db in target_dbs:
            target_db.collection(collection_name).document(doc.id).set(payload)
            print(f"Synced to {target_name} {collection_name}: {doc.id}")
        doc.reference.update({SYNC_TO_DB2_FIELD: True})
        updated += 1
        print(f"Marked synced in source {collection_name}: {doc.id}")

    print(f"{collection_name}: synced {updated}")
    return updated


def sync_history_collection(source_db, reports_db, collection_name):
    synced = 0
    last_seen = None
    last_seen_doc_id = None
    state_key = f"reports__{collection_name}"
    state_doc = state_ref(source_db, state_key).get()
    state = state_doc.to_dict() or {}
    last_log_date = state.get("lastLogDate")
    last_doc_id = state.get("lastDocId")

    query = source_db.collection(collection_name)
    if last_log_date is not None:
        query = query.where(LOG_DATE_FIELD, ">=", last_log_date)

    query = query.order_by(LOG_DATE_FIELD).order_by("__name__")

    for doc in query.stream():
        doc_data = doc.to_dict() or {}
        doc_log_date = doc_data.get(LOG_DATE_FIELD)

        if (
            last_log_date is not None
            and doc_log_date == last_log_date
            and last_doc_id is not None
            and doc.id <= last_doc_id
        ):
            continue

        payload = normalize_payload(doc_data, collection_name, doc.id)
        reports_db.collection(collection_name).document(doc.id).set(payload)
        synced += 1
        last_seen = doc_log_date
        last_seen_doc_id = doc.id
        print(f"Synced history {collection_name}: {doc.id}")

    if last_seen is not None:
        state_ref(source_db, state_key).set(
            {
                "lastLogDate": last_seen,
                "lastDocId": last_seen_doc_id,
                "updatedAt": firestore.SERVER_TIMESTAMP,
            }
        )

    print(f"{collection_name}: history synced {synced}")
    return synced


def process_delete_queue(source_db, target_dbs):
    processed = 0

    for doc in source_db.collection(SYNC_DELETE_QUEUE).stream():
        payload = doc.to_dict() or {}
        source_collection = payload.get("sourceCollection")
        source_doc_id = payload.get("docId")

        if not source_collection or not source_doc_id:
            print(f"Skipping invalid delete queue doc: {doc.id}")
            continue

        for target_name, target_db in target_dbs:
            target_db.collection(source_collection).document(source_doc_id).delete()
            print(f"Deleted from {target_name} {source_collection}: {source_doc_id}")
        doc.reference.delete()
        processed += 1
        print(f"Removed delete queue item: {doc.id}")

    print(f"{SYNC_DELETE_QUEUE}: processed {processed}")
    return processed


def main():
    source_db = init_db(SOURCE_SECRET, "source")
    reports_db = init_db(REPORTS_SECRET, "reports")
    loyalty_db = init_db(LOYALTY_SECRET, "loyalty")
    target_dbs = [
        ("reports", reports_db),
        ("loyalty", loyalty_db),
    ]

    sync_pending_collection(source_db, target_dbs, JOBS_DONE)
    sync_pending_collection(source_db, target_dbs, JOBS_COMPLETED)
    sync_history_collection(source_db, reports_db, SUPPLIES_HIST)
    sync_history_collection(source_db, reports_db, ITEMS_HIST)
    sync_history_collection(source_db, reports_db, EMPLOYEE_HIST)
    process_delete_queue(source_db, target_dbs)

    print("Done.")


if __name__ == "__main__":
    main()
