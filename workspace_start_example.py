#Importing the AWS SDK
import boto3

#Creading workspace client object 
client = boto3.client("workspaces")

#Description of all running workspace
response = client.describe_workspaces()

#Looping over all workspaces in response
for workspace in response["Workspaces"]:

    #Some temporary variables for each workspace
    state = str(workspace["State"])
    username = str(workspace["UserName"])
    workspaceId = str(workspace["WorkspaceId"])
    runningMode = workspace["WorkspaceProperties"]["RunningMode"]
    
    
    #Starting turned off workspaces
    if state=="STOPPED":

        #Starting workspace with the id stored in varibale workspaceId
        client.start_workspaces(StartWorkspaceRequests = [
            {
                "WorkspaceId": workspaceId
            }
            ])
    #Checking if the running mode is Auto Stop
    if runningMode=="AUTO_STOP":
        #Making the auto stop timeout 180 minutes
        client.modify_workspace_properties(
            WorkspaceId = workspaceId,
            WorkspaceProperties = {
                'RunningModeAutoStopTimeoutInMinutes' : 180
            }
        )
        
