def update_permissions(event, context):
  import sys
  import os
  """Background Cloud Function to be triggered by Cloud Storage.

  Args:
      event (dict):  The dictionary with data specific to this type of event.
                     The `data` field contains a description of the event in
                     the Cloud Storage `object` format described here:
                     https://cloud.google.com/storage/docs/json_api/v1/objects#resource
      context (google.cloud.functions.Context): Metadata of triggering event.
  Returns:
      None; the function reads the service accounts from blob and grant them IAM roles
  """
  sa_list = []
  validated_sa_list = []
  roles = ['roles/gkehub.gatewayEditor']
  project_id = os.environ['GCP_PROJECT']
  print('Printing the payload.\n')
  print('EVENT:' , event)
  print('Event ID:' , context.event_id)
  print('Event type:', context.event_type)
  print('Bucket:', event['bucket'])
  print('File:',  event['name'])
  print('Metageneration:',  event['metageneration'])
  print('Created:',  event['timeCreated'])
  print('Updated:',  event['updated'])
  bucket_name = event['bucket']
  blob_name = event['name']

  print('Fetching Service Accounts from the file',bucket_name + '/' + blob_name)
  try:
    sa_list = fetch_sa_from_file(bucket_name,blob_name)
  except Exception as e:
    print('Unable to fetch Service Accounts from ' + bucket_name + '/' + blob_name + '.')
    exception_handler('fetch_sa_from_file', str(e))

  print('Fetching policy of the project.\n')
  try:
    policy = get_policy(project_id)
    print('The policy is \n', policy)
  except Exception as e:
    print('Unable to fetch policy of the project ' + project_id)
    exception_handler('get_policy', str(e))

  for sa in sa_list:
    for role in roles:
      try:
        print('Adding role ' + role + ' to the member ' + sa)
        policy = generate_modified_policy(policy,role,sa)
      except Exception as e:
        print('Unable to create modified policy')
        exception_handler('generate_modified_policy', str(e))

  print('Setting the generated policy so the Service Accounts get the required roles.\n')
  try:
    policy = set_policy(project_id,policy)
    print('Printing new policy', policy)
  except Exception as e:
    print('Unable to set the policy \n.')
    exception_handler('set_policy', str(e))


def fetch_sa_from_file(bucket_name, blob_name):
  """Function to fetch the Service Accounts written in the text GCS object.
  Args:
      bucket_name (string):  GCS bucket name.
      blob_name (string): Object containing the service accounts.
  Returns:
      sa_list (list); list containing service accounts
  """
  from google.cloud import storage
  storage_client = storage.Client()
  bucket = storage_client.bucket(bucket_name)
  blob = bucket.blob(blob_name)
  sa_list = []
  with blob.open("r") as f:
    sa_list.extend(f.read().split())
  return(sa_list)

def get_policy(project_id):
  """Function to fetch the policy of the project.
  Args:
      project_id (string); project id whose policy is to be fetched.

  Returns:
      policy (dict);  returns IAM policy.
  """
  import os
  from google.oauth2 import service_account
  import googleapiclient.discovery
  service = googleapiclient.discovery.build(
      "cloudresourcemanager", "v1"
  )
  policy = (
      service.projects()
      .getIamPolicy(
          resource=project_id,
          body={"options": {"requestedPolicyVersion": 1}},
      )
      .execute()
  )
  return(policy)

def generate_modified_policy(policy, role, member):
  """Function to generate the new policy of the project.
  Args:
      policy (string); IAM policy of the project.
      role (string); IAM role that needs to be added to the policy for the given member.
      member (string); Service Account which needs to be added for the roles in the policy.

  Returns:
      policy (dict); new IAM policy of the project.
  """
  import os
  from google.oauth2 import service_account
  import googleapiclient.discovery
  role_binding_exists = 0
  #If role binding exists, add a member
  for b in policy['bindings']:
    if b["role"] == role:
      b["members"].append('serviceAccount:' + member)
      role_binding_exists = 1
      break
  #If role binding doesnt exists, add one
  if role_binding_exists == 0:
    binding = {"role": role, "members": ['serviceAccount:' + member]}
    policy["bindings"].append(binding)

  print(policy)
  return policy

def set_policy(project_id,policy):
  """Function to fetch the policy of the project.
  Args:
      project_id(string)
      policy (dict); generated IAM policy of the project that needs to be set.

  Returns:
      new IAM policy.
  """
  import os
  from google.oauth2 import service_account
  import googleapiclient.discovery

  service = googleapiclient.discovery.build(
      "cloudresourcemanager", "v1"
  )
  policy = (
      service.projects()
      .setIamPolicy(resource=project_id, body={"policy": policy})
      .execute()
  )
  return policy

def exception_handler(function,message):
  """Function to handle exceptions and exit.
  Args:
      function (string); name of the function
      message(string); error message

  Returns:
      NA
  """
  import sys
  print('Function ' + function + ' failed with the following error: ' + message)
  print('Exiting with status code 1..')
  sys.exit(1)
