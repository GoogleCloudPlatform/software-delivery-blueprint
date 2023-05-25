def update_permissions(event, context):
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
  roles = ['roles/billing.user']
  billing_acc_secret_name = 'gcp-billingac'
  project_id = os.environ['GCP_PROJECT']
  secret_project = 'YOUR_SECRET_PROJECT_ID'
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

  print('Fetch the billing account.\n')
  try:
    billing_ac = get_billing_ac(billing_acc_secret_name,secret_project)
    print('The billing account is \n', billing_ac)
  except Exception as e:
    print('Unable to fetch billing account')
    exception_handler('get_billing_ac', str(e))

  print('Fetching policy of the billing account.\n')
  try:
    policy = get_policy(billing_ac)
    print('The policy is \n', policy)
  except Exception as e:
    print('Unable to fetch policy of the billing account ' + billing_ac)
    exception_handler('get_policy', str(e))

  for sa in sa_list:
    for role in roles:
      try:
        print('Adding role ' + role + ' to the member ' + sa)
        policy = generate_modified_policy(policy,role,sa)
      except Exception as e:
        print('Unable to create modified policy')
        exception_handler('generate_modified_policy', str(e))
  print('Generated policy is ', policy)
  print('Setting the generated policy so the Service Accounts get the required roles.\n')
  try:
    policy = set_policy(billing_ac,policy)
  except Exception as e:
    print('Unable to set the policy \n.')
    exception_handler('set_policy', str(e))
  print('Successfully set the policy ', policy)


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

def get_billing_ac(billing_acc_secret_name,secret_project):
  """Function to fetch the billing account.
   Args:
      billing_acc_secret_name (string); secret that holds the billing account.
      secret_project; project where the secret exists.
   Returns:
      account (string);  billing account.
  """
  from google.cloud import secretmanager_v1
  secret = "projects/" + secret_project + "/secrets/" + billing_acc_secret_name + "/versions/latest"
  client = secretmanager_v1.SecretManagerServiceClient()
  request = secretmanager_v1.AccessSecretVersionRequest(
      name=secret,
  )
  response = client.access_secret_version(request=request)
  account = str(response.payload.data,'utf-8')
  return(account)


def get_policy(billing_ac):
  """Function to fetch the policy of the billing account.
  Args:
      billing_ac (string); billing account.

  Returns:
      policy (dict);  returns IAM policy.
  """
  from google.cloud import billing_v1
  from google.iam.v1 import iam_policy_pb2
  from google.protobuf.json_format import MessageToDict
  client = billing_v1.CloudBillingClient()
  request = iam_policy_pb2.GetIamPolicyRequest(
      resource="billingAccounts/" + billing_ac,
  )
  response = client.get_iam_policy(request=request)
  return(MessageToDict(response))


def generate_modified_policy(policy, role, member):
  """Function to generate the new policy of the billing account.
  Args:
      policy (string); IAM policy of the billing account.
      role (string); IAM role that needs to be added to the policy for the given member.
      member (string); Service Account which needs to be added for the roles in the policy.

  Returns:
      policy (dict); new IAM policy of the billing account.
  """
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

  return(policy)

def set_policy(billing_ac,policy):
  """Function to set the policy of the billing account.
  Args:
      billing_ac(string); billing account
      policy (dict); generated IAM policy of the billing account that needs to be set.

  Returns:
      new IAM policy.
  """
  from google.cloud import billing_v1
  from google.iam.v1 import iam_policy_pb2
  from google.iam.v1 import policy_pb2
  from google.protobuf.json_format import MessageToDict
  from google.protobuf.json_format import ParseDict

  client = billing_v1.CloudBillingClient()
  policy = ParseDict(policy,policy_pb2.Policy())
  request = iam_policy_pb2.SetIamPolicyRequest(
      resource="billingAccounts/" + billing_ac,
      policy=policy,
  )
  response = client.set_iam_policy(request=request)
  return(MessageToDict(response))


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
