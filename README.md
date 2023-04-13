## Devops-project
![Screenshot from 2023-01-23 18-52-06 (1)](https://user-images.githubusercontent.com/91377914/230330361-6368dde0-996b-4457-a6cd-cebc464e5d7d.png)


# Install the gcloud CLI
follow this link to install Google cloud CLI
https://cloud.google.com/sdk/docs/install

# Create Service Account fot Terraform
gcloud iam service-accounts create NAME [--description=DESCRIPTION] [--display-name=DISPLAY_NAME] [GCLOUD_WIDE_FLAG …]

gcloud iam service-accounts keys create key.json --iam-account=my-iam-account@my-project.iam.gserviceaccount.com

store credential in github secrets as GOOGLE_CREDENTIALS
also define BASENAME and REGION
change the PROJECT_ID and number in variable.tf or in GOOGLE_CREDENTIALS
# Create a bucket to store Terraform state
gcloud storage buckets create gs://BUCKET_NAME
# Use github secret to manage Google Credential
Make sure you have the necessary Cloud Storage permissions on your user account:
storage.buckets.create
storage.buckets.list
storage.objects.get
storage.objects.create
storage.objects.delete
storage.objects.update


# API should be enabled
Artifact Registry API 
Cloud Resource Manager API
Identity and Access Management (IAM) API
