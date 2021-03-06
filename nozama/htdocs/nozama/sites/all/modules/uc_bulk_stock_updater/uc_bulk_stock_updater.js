// $Id: uc_bulk_stock_updater.js,v 1.2 2010/08/29 18:12:29 hiddentao Exp $


Drupal.behaviors.uc_bulk_stock_updater = function (context) {
	
	// keep track of which stock levels get edited
	$("input.uc_bulk_stock_updater_value").each(function(){
		$(this).data("original", $(this).val());
		$(this).change(function(){
			uc_bulk_stock_updater_submitStockValue(this);
		})
	});

	// filter
	$("#uc_bulk_stock_updater_filter").keyup(function(){
		
		$(this).after("<div class=\"uc_bulk_stock_updater_ajax_progress\"></div>");
		
		var f = $(this).val().toLowerCase();
		if ('' == f)
			$("table.uc-stock-table tr").show();
		else {
			$("table.uc-stock-table tr").each(function(){
				// show 
				if (0 < $(this).find("span[id*=" + f + "]").size()) {
					$(this).show();
				} else {
					$(this).hide();
				}
			});
		}
		
		$(this).next("div.uc_bulk_stock_updater_ajax_progress").remove();		
	});
};


function uc_bulk_stock_updater_submitStockValue(stockInputElem)
{
	var _sku = $(stockInputElem).attr("name");
	var _stock = $(stockInputElem).val();

	// reset error msgs
	$(stockInputElem)
		.removeClass("error")
		.after("<div class=\"uc_bulk_stock_updater_ajax_progress\"></div>");
	
	$(stockInputElem).nextAll("div.uc_bulk_stock_updater_ajax_error").remove();
	
	// call
	$.ajax({
		url : Drupal.settings.uc_bulk_stock_updater.ajax_url,
		type: 'POST',
		timeout : 3000,
		data : { sku: _sku, stock: _stock },
		dataType : "json",
	    error : function(_XMLHttpRequest, _textStatus, _errorThrown)
	    {
			uc_bulk_stock_updater_submitStockValueErr(stockInputElem, _textStatus);
	    },			
		success : function(_data, _textStatus, _XMLHttpRequest)
		{
	    	if (undefined != _data.error)
	    		uc_bulk_stock_updater_submitStockValueErr(stockInputElem, _data.error);
	    	else
	    		$(stockInputElem).data("original", _stock);
	    },
		complete : function(_XMLHttpRequest,_textStatus)
		{
			$(stockInputElem).nextAll("div.uc_bulk_stock_updater_ajax_progress").remove();
		}	    
	});	
}
function uc_bulk_stock_updater_submitStockValueErr(stockInputElem, _errorMsg)
{
	$(stockInputElem)
		.after("<div class=\"uc_bulk_stock_updater_ajax_error\">" + _errorMsg + "</div>")
		.val($(stockInputElem).data("original"))
		.addClass("error");
}


