## Devops-project
![Screenshot from 2023-01-23 18-52-06 (1)](https://user-images.githubusercontent.com/91377914/230330361-6368dde0-996b-4457-a6cd-cebc464e5d7d.png)


# Install the gcloud CLI
follow this link to install Google cloud CLI
https://cloud.google.com/sdk/docs/install


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


#
