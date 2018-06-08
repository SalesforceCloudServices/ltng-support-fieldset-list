({
    /**
     * Initialization of the component.
     */
    init: function(component, event, helper) {
        //console.log('FieldSetFormController.init');
        helper.setup(component, helper );
	},
    
    /**
     * Handles when the 'initiateSave' method is called (from the parent)
     */
	handleInitiateSave : function(component, event, helper){
        //console.info('initiate save request recieved from parent');
        helper.initiateFieldListSave(component, helper);
    },

    /**
     * Handles when the 'activateSave' method is called (from the parent)
     */
    handleActivateSave : function(component, event, helper){
        //console.info('activate save request recieved from parent');
        helper.activateFieldListSave(component, helper);
    },
    
    /**
     * Handles the success for saving the form
     */
    handleFormSuccess : function(component, event, helper){
        //console.info('form saved successfully');
        helper.notifySaveSuccess(component, helper, true);
    },

    /**
     * Handles the error occurred when saving the form
     */
    handleFormError : function(component, event, helper){
        //console.error('error occurred while saving the form');
        helper.notifySaveSuccess(component, helper, true);
    }
})