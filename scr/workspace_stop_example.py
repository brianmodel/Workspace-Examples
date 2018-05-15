#Importing the aws SDK
import boto3

#Creading workspace client object 
client = boto3.client("workspaces")

#Description of all running workspace
response = client.describe_workspaces()

#Looping over all workspaces in response
for workspace in response["Workspaces"]:

    #Some temporary variables for each workspace
    RunningMode = workspace["WorkspaceProperties"]["RunningMode"]
    workspaceId = str(workspace["WorkspaceId"])

    #Checking if the running mode is Auto Stop
    if RunningMode=="AUTO_STOP":
        #Making the auto stop timeout 60 minutes
        client.modify_workspace_properties(
            WorkspaceId = workspaceId,
            WorkspaceProperties =
            {
                'RunningModeAutoStopTimeoutInMinutes' : 60
            }
        )
        
