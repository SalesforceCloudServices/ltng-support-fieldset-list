({
	/**
	 *  Determines if the a large string contains a smaller string
	 */
	checkIfHaystackContainsNeedle : function(component) {
		var searchInside = component.get('v.searchInside');
		var valueToFind = component.get('v.valueToFind');
		var foundValue = true;
		
		//-- only search if both have info
		if( !$A.util.isEmpty(searchInside) && !$A.util.isEmpty(valueToFind) ){

			//-- case sensitive search
			searchInside = searchInside.toLowerCase();
			valueToFind = valueToFind.toLowerCase();

			foundValue = searchInside.indexOf(valueToFind) > -1;
		}

		component.set('v.foundValue', foundValue);
	}
})