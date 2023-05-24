import json
import sys

"""
Script accepts three parameters : input file(json formatted) , output file , role, user that needs to be added the role
If the json input passed has an entry for role:"roles/<ROLE>" and the user exists as its member, no action is taken
If the json input passed has an entry for role:"roles/<ROLE>" and the user doesn't exists as its member, it is added to members list
If the json input passed has no entry for role:"roles/<ROLE>", an entry is added with user as member and role as "roles/<ROLE>
"""

input = sys.argv[1]
output = sys.argv[2]
role = sys.argv[3]
users = sys.argv[4].split(',')
users = [ "serviceAccount:" + user  for user in users ]
flag=0
with open(input) as f:
  input = json.load(f)

for user in users:
  for k,v in input.items():
    if k == "bindings":
      for list_item_dict in v:
        if 'role' in list_item_dict and list_item_dict['role']=="roles/" + role :
          if user in list_item_dict['members']:
            flag = 1 #no change needed as the user already exists as roles/<ROLE>
          else:
            list_item_dict['members'].append(user)
            flag = 1 #added the user as roles/<ROLE>

  if flag == 0: # No entry was found for roles/<ROLE>
    #print(input['bindings'])
    for k,v in input.items():
      if k == "bindings":
        v.append({"members":[user],"role":"roles/" + role })

  with open(output,'w') as f:
    json.dump(input,f,indent=2)
