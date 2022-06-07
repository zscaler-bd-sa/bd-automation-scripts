if (current.operation() != 'insert' && current.comments.changes()) {
	if (!isConnect())
		gs.eventQueue("incident.commented", current, gs.getUserID(), gs.getUserName());
}

if (current.operation() == 'insert') {
 gs.eventQueue("incident.inserted", current, gs.getUserID(), gs.getUserName());
}

if (current.operation() == 'update'&& !current.comments.changes()) {
 gs.eventQueue("incident.updated", current, gs.getUserID(), gs.getUserName());
}

if (!current.assigned_to.nil() && current.assigned_to.changes()) {
  gs.eventQueue("incident.assigned", current, current.assigned_to.getDisplayValue() , previous.assigned_to.getDisplayValue());
}

if (!current.assignment_group.nil() && current.assignment_group.changes()) {
  gs.eventQueue("incident.assigned.to.group", current, current.assignment_group.getDisplayValue() , previous.assignment_group.getDisplayValue());
}


if (current.priority.changes() && current.priority == 1) {
  gs.eventQueue("incident.priority.1", current, current.priority, previous.priority);
}

if (current.severity.changes() && current.severity== 1) {
  gs.eventQueue("incident.severity.1", current, current.severity, previous.severity);
}

if (current.escalation.changes() && current.escalation > previous.escalation && previous.escalation != -1) {
  gs.eventQueue("incident.escalated", current, current.escalation , previous.escalation );
}

if (current.active.changesTo(false)) {
  gs.eventQueue("incident.inactive", current, current.incident_state, previous.incident_state);
  gs.workflowFlush(current);
}

if (current.category == 'TFE run' && current.resolved_at != '') {
    gs.info("Preparing to send TFE API request");
    var requestBody;
    var responseBody;
    var status;
    try {
        // On the Scripted Rest API that receives TFE notification, we put the json data on the incident's description
        // In this block we will reverse that to a json object
        var parser = new JSON();
        var str = current.description;
        var obj = parser.decode(str);

        // Creates message
        var r = new sn_ws.RESTMessageV2();
        r.setEndpoint("https://app.terraform.io/api/v2/runs/" + obj.run_id + "/actions/apply");
        r.setHttpMethod("POST");
        // Make sure you update the TFE token
        r.setRequestHeader("Authorization", "Bearer " + "INSERT_TERRAFORM_CLOUD_TOKEN");
        r.setRequestHeader('Content-Type', 'application/vnd.api+json');

        var response = r.execute();
        responseBody = response.haveError() ? response.getErrorMessage() : response.getBody();
        status = response.getStatusCode();
    } catch (ex) {
        responseBody = ex.getMessage();
        status = '500';
    } finally {
        gs.info("API call to TFE was successful");
        requestBody = r ? r.getRequestBody() : null;
    }
    gs.info("Request Body: " + requestBody);
    gs.info("Response: " + responseBody);
    gs.info("HTTP Status: " + status);
}