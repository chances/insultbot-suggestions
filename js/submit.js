/**
 * @author Chance Snow
 */
$(function () {
	var $submitInsult = $('#submitInsult'),
		$submitInsultPanel = $('#submitInsultPanel'),
		$insult = $('#insult'),
		$insertNick = $('#insertNick'),
    	$error = $('#error'),
    	selStart = 0,
    	selEnd = 0;
	
	$error.hide();
	
	$insertNick.on('click', function () {
		var val = $insult.val(),
			parts = [];
		parts.push(val.substring(0, selStart));
		parts.push('<NICK>');
		parts.push(val.substring(selEnd));
		$insult.val(parts.join(''));
		if (selStart == selEnd) {
			selEnd = selStart += 6;
		} else {
			selEnd = selStart + 6;
		}
		$insult.prop('selectionStart', selStart).prop('selectionEnd', selEnd);
		//Remove error from form
        $submitInsult.find('.form-group').removeClass('has-error');
        $submitInsultPanel.addClass('center-vert');
        $error.hide();
	});
	
	$insult.on('mousemove', function () {
		//Get selection
		selStart = $insult.prop('selectionStart');
		selEnd = $insult.prop('selectionEnd');
	}).on('keyup', function () {
		//Get selection
		selStart = $insult.prop('selectionStart');
		selEnd = $insult.prop('selectionEnd');
		//Hide error if need be
		var val = $insult.val().trim();
		if (val) {
			//Remove error from form
	        $submitInsult.find('.form-group').removeClass('has-error');
	        $submitInsultPanel.addClass('center-vert');
	        $error.hide();
		}
	});
	
	$submitInsult.submit(function (event) {
		//Remove error from form
        $submitInsult.find('.form-group').removeClass('has-error');
        $submitInsultPanel.addClass('center-vert');
        
        if (!$insult.val().replace(/\s+/g, '')) {
        	$submitInsultPanel.addClass('animated shake').removeClass('center-vert');
        	window.setTimeout(function () {
        		$submitInsultPanel.removeClass('animated shake');
        	}, 1000);
        	$insult.focus().parent().addClass('has-error');
        	
        	//Show error message
            if ($error.is(':hidden')) { $error.show(); }
            event.preventDefault();
        } else {
        	$error.hide();
        }
	});
	
	//Insult list stuffs
	var $insults = $('#insults');
	
	$insults.find('tbody > tr').each(function () {
		$(this).find('.editing').hide();
		$(this).find('.edit').click(function () {
			$(this).parent().find('.not-editing').hide();
			$(this).parent().find('.editing').show();
		});
		$(this).find('.cancel').click(function () {
			$(this).parent().find('.editing').hide();
			$(this).parent().find('.not-editing').show();
		});
		$(this).find('.save').click(function () {
			//$(this).parent().find('.editing').hide();
			//$(this).parent().find('.not-editing').show();
		});
	});
});
