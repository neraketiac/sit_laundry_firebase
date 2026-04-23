import json
import os

import firebase_admin
from firebase_admin import credentials, firestore


SOURCE_SECRET = "FIREBASE_SOURCE_SERVICE_ACCOUNT"
REPORTS_SECRET = "FIREBASE_REPORTS_SERVICE_ACCOUNT"

SOURCE_COLLECTION = "Jobs_done"
TARGET_COLLECTION = "jobs_done_reports_raw"


def init_db(secret_name: str, app_name: str):
    raw = os.environ.get(secret_name)
    if not raw:
        raise RuntimeError(f"Missing environment variable: {secret_name}")

    service_account = json.loads(raw)
    cred = credentials.Certificate(service_account)
    app = firebase_admin.initialize_app(cred, name=app_name)
    return firestore.client(app)


def main():
    source_db = init_db(SOURCE_SECRET, "source")
    reports_db = init_db(REPORTS_SECRET, "reports")

    docs = source_db.collection(SOURCE_COLLECTION).stream()

    copied = 0
    for doc in docs:
        data = doc.to_dict() or {}
        data["_source_doc_id"] = doc.id
        data["_source_collection"] = SOURCE_COLLECTION

        reports_db.collection(TARGET_COLLECTION).document(doc.id).set(data)
        copied += 1
        print(f"Copied {doc.id}")

    print(f"Done. Total copied: {copied}")


if __name__ == "__main__":
    main()
