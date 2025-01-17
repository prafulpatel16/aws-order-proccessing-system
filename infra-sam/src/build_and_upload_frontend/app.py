import os
import subprocess
import boto3

def lambda_handler(event, context):
    # Paths
    frontend_path = "/tmp/frontend"
    build_path = "/tmp/frontend/build"
    s3_bucket_name = os.getenv("S3_BUCKET_NAME")
    
    # Clone or copy the frontend folder
    local_src_path = "./frontend"  # Adjust this to where your frontend folder is packaged
    subprocess.run(["cp", "-r", local_src_path, frontend_path])

    # Install dependencies
    subprocess.run(["npm", "install"], cwd=frontend_path, check=True)

    # Build the React application
    subprocess.run(["npm", "run", "build"], cwd=frontend_path, check=True)

    # Upload build artifacts to S3
    s3 = boto3.client("s3")
    for root, dirs, files in os.walk(build_path):
        for file in files:
            file_path = os.path.join(root, file)
            s3_key = os.path.relpath(file_path, build_path)
            s3.upload_file(file_path, s3_bucket_name, s3_key, ExtraArgs={"ACL": "public-read"})

    return {"status": "Frontend built and uploaded successfully!"}
