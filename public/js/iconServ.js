
(function() {
    
    $(document).ready(function() {
  		
  		$("#domainSubmitButton").click(function() {
  			
  			var domainEntry = $("#domainInput").val();
  			var url = "icons/" + domainEntry;
  			
  			clearExistingData();
  			
  			$.get("icons/" + domainEntry, function(result)
  			{		
  				
  				addData(result);
  			});
  			
  		});
  		
	});
	
	function clearExistingData()
	{
		$(".iconData").remove();
	}
	
	function addData(data)
	{
		var icons = data.icons;
		
		if(icons.length == 0)
		{
			showNoResults();
		}
		
		for (var index=0; index < icons.length; index++)
		{
			addDataItem(icons[index]);
		}
	}
	
	function showNoResults()
	{
		var htmlString = "<div class='iconData'>No icons returned</div>";
		$("#results").append(htmlString);
	}
	
	function addDataItem(dataItem)
	{
		var htmlForData = "<div class='iconData'>"
							+ "<p>domain: " + dataItem.domain + "</p>" 
							+ "<p>fileFormat: " + dataItem.fileFormat + "</p>"
							+ "<p>height: " + dataItem.height + "</p>"
							+ "<p>width: " + dataItem.width + "</p>"
							+ "<p>url: " + dataItem.url + "</p>"
							+ "<p><img src='" + dataItem.url + "'>";
		$("#results").append(htmlForData);
	}
    
})();