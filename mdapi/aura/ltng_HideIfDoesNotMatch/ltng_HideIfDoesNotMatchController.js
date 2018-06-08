({
	init : function(component, event, helper) {
		//-- determine if the needle contains the haystck
		helper.checkIfHaystackContainsNeedle(component, event, helper);
	},

	handleNeedleHaystackChanged : function(component, event, helper){
		//console.info('needleHaystackChanged');
		//-- determine if the needle contains the haystck
		helper.checkIfHaystackContainsNeedle(component, event, helper);
	}
})