import json
import os

import firebase_admin
from firebase_admin import credentials, firestore


SOURCE_SECRET = "FIREBASE_SOURCE_SERVICE_ACCOUNT"
REPORTS_SECRET = "FIREBASE_REPORTS_SERVICE_ACCOUNT"

JOBS_DONE = "Jobs_done"
JOBS_COMPLETED = "Jobs_completed"
SYNC_DELETE_QUEUE = "sync_delete_queue"
SYNC_TO_DB2_FIELD = "Z00_IsSyncToDB2"


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


def sync_pending_collection(source_db, reports_db, collection_name):
    updated = 0

    docs = source_db.collection(collection_name).where(
        SYNC_TO_DB2_FIELD, "==", False
    ).stream()

    for doc in docs:
        payload = normalize_payload(doc.to_dict(), collection_name, doc.id)
        reports_db.collection(collection_name).document(doc.id).set(payload)
        doc.reference.update({SYNC_TO_DB2_FIELD: True})
        updated += 1
        print(f"Synced {collection_name}: {doc.id}")

    print(f"{collection_name}: synced {updated}")
    return updated


def process_delete_queue(source_db, reports_db):
    processed = 0

    for doc in source_db.collection(SYNC_DELETE_QUEUE).stream():
        payload = doc.to_dict() or {}
        source_collection = payload.get("sourceCollection")
        source_doc_id = payload.get("docId")

        if not source_collection or not source_doc_id:
            print(f"Skipping invalid delete queue doc: {doc.id}")
            continue

        reports_db.collection(source_collection).document(source_doc_id).delete()
        doc.reference.delete()
        processed += 1
        print(f"Deleted from reports {source_collection}: {source_doc_id}")

    print(f"{SYNC_DELETE_QUEUE}: processed {processed}")
    return processed


def main():
    source_db = init_db(SOURCE_SECRET, "source")
    reports_db = init_db(REPORTS_SECRET, "reports")

    sync_pending_collection(source_db, reports_db, JOBS_DONE)
    sync_pending_collection(source_db, reports_db, JOBS_COMPLETED)
    process_delete_queue(source_db, reports_db)

    print("Done.")


if __name__ == "__main__":
    main()
