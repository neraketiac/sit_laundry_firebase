import json
import os

import firebase_admin
from firebase_admin import credentials, firestore


# ENV variable names (match your PowerShell)
SOURCE_SECRET = "FIREBASE_SOURCE_SERVICE_ACCOUNT"
DESTINATION_SECRET = "FIREBASE_GCASH_SERVICE_ACCOUNT"

# Collection to transfer
COLLECTION_NAME = "GCash_pending"


def init_db(secret_name: str, app_name: str):
    raw = os.environ.get(secret_name)

    if not raw:
        raise RuntimeError(f"Missing environment variable: {secret_name}")

    try:
        # ✅ If ENV is a file path
        if os.path.exists(raw):
            print(f"Using file path for {app_name}: {raw}")
            cred = credentials.Certificate(raw)

        # ✅ If ENV is JSON string
        else:
            print(f"Using JSON content from ENV for {app_name}")
            service_account = json.loads(raw)
            cred = credentials.Certificate(service_account)

        app = firebase_admin.initialize_app(cred, name=app_name)
        return firestore.client(app)

    except Exception as e:
        raise RuntimeError(f"Failed to init {app_name}: {e}")


def copy_collection(source_db, destination_db):
    copied = 0
    failed = 0

    print(f"Starting copy of '{COLLECTION_NAME}' collection...\n")

    docs = source_db.collection(COLLECTION_NAME).stream()

    batch = destination_db.batch()
    batch_count = 0

    for doc in docs:
        try:
            data = doc.to_dict()

            batch.set(
                destination_db.collection(COLLECTION_NAME).document(doc.id),
                data
            )

            batch_count += 1
            copied += 1

            if batch_count >= 500:
                batch.commit()
                print(f"Committed batch: {copied} docs copied...")
                batch = destination_db.batch()
                batch_count = 0

        except Exception as e:
            failed += 1
            print(f"Error copying {doc.id}: {e}")

    if batch_count > 0:
        batch.commit()
        print(f"Committed final batch: {batch_count} docs")

    print("\n" + "=" * 50)
    print("Copy completed!")
    print(f"Success: {copied}")
    print(f"Failed: {failed}")
    print("=" * 50)

    return copied, failed


def main():
    print("Initializing Firebase connections...\n")

    try:
        source_db = init_db(SOURCE_SECRET, "source")
        destination_db = init_db(DESTINATION_SECRET, "destination")

        print("\n✓ Connected to source database")
        print("✓ Connected to destination database\n")

        copied, failed = copy_collection(source_db, destination_db)

        if failed == 0:
            print("\n✅ All documents copied successfully!")
        else:
            print(f"\n⚠️ Completed with {failed} error(s)")

    except RuntimeError as e:
        print(f"\n❌ Config error: {e}")
        print("\nRequired ENV variables:")
        print(f"  - {SOURCE_SECRET}")
        print(f"  - {DESTINATION_SECRET}")
        exit(1)

    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        exit(1)


if __name__ == "__main__":
    main()