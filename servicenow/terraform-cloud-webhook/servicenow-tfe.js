(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var data = request.body.data;

    // Will only be triggered if it is a pending Terraform apply
    // Sample TFE payload: https://www.terraform.io/docs/enterprise/api/notification-configurations.html#sample-payload:
    if (data.notifications[0].trigger == 'run:needs_attention') {
        var run_url = data.run_url.toString();
        var run_id = data.run_id.toString();
        var organization_name = data.organization_name.toString();
        var workspace_name = data.workspace_name.toString();
        var run_created_by = data.run_created_by.toString();
        var message = data.notifications[0].message.toString();

        var grI = new GlideRecord('sys_user');

        gs.log(gs.getUserID());

        grI.addQuery('sys_id', gs.getUserID());

        grI.queryNoDomain();

        if (grI.next()) {
            // Creates a new incident
            var gr = new GlideRecord('incident');
            gr.initialize();
            gr.setValue('category', 'TFE run');
            gr.setValue('subcategory', 'Confirm apply');
            gr.setValue('short_description', 'Confirm apply for ' + organization_name + '/' + workspace_name);

            // This will store the json object from Terraform in the description field
            var parser = new JSON();
            var str = parser.encode(data);
            gr.setValue('description', str);

            // Feel free to change per organization's needs
            gr.setValue('comments', 'Created by ' + run_created_by);
            gr.setValue('urgency', '3');
            gr.setValue('impact', '3');
            gr.setValue('caller_id', 'n/a');
            gr.setValue('contact_type', 'WebService');
            gr.setValue('company', grI.getValue('company'));
            gr.setValue('location', grI.getValue('location'));
            gr.setValue('caller_id', gs.getUserID());
            gr.sys_domain = gs.getUser().getDomainID();
            gr.insert();

            var number = gr.getValue('number');
            var state = gr.state;

            return {
                "incident_number": number,
                "state": state,
                "domain": gr.getDisplayValue('sys_domain')
            };
        }
    } else {
        gs.info("Received notification from Terraform, but it wasn't a pending apply");
        gs.info("Terraform request: " + request.body.data.toString());
    }
})(request, response);