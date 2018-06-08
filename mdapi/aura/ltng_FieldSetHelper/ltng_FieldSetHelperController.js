({
	init : function(component, event, helper) {
		console.info('ltng_FieldSetHelper initialized');

		var recordId = component.get('v.recordId');

		helper.reset(component, helper);

		helper.initializeSObjectInfo(component, helper, recordId);
	}
})