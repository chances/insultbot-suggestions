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
	var $insults = $('#insults'),
        $deleteDialog = $('#deleteModal'),
        $delete = $('#delete');
	
	$insults.find('tbody > tr').each(function () {
		$(this).find('.editing').css('display', 'none');

		$(this).find('.edit').click(function () {
			var $actions = $(this).parent(),
                $row = $actions.parent(),
                $icon = $row.find('span.glyphicon'),
				$insult = $actions.parent().find('td.insult'),
                $form = $('<form class="form-group" method="post"></form>'),
				insult = $insult.data('insult'),
                insultId = $insult.parent().data('insult-id'),
                handle = $insults.data('handle'),
                $input = $('<input class="form-control" type="text" name="insult" value="' + insult + '">');
			$actions.find('.not-editing').css('display', 'none');
			$actions.find('.editing').css('display', 'inherit');
			$form.append($input);
            $form.submit(function (event) {
                event.preventDefault();
                $form.removeClass('has-error');
                var value = $input.val();
                if (!value.replace(/\s+/g, '')) {
                    $form.addClass('has-error');
                } else {
                    if (value !== insult) {
                        $row.addClass('loading');
                        $input.attr('disabled','');
                        $actions.find('.editing').css('display', 'none');
                        $.post('/~chances/insults/insult/' + insultId, {insult: value}, function (response) {
                            response = JSON.parse(response);
                            $row.removeClass('loading');
                            if (response.success === true) {
                                $input.removeAttr('disabled');
                                $icon.removeClass('glyphicon-ok').addClass('glyphicon-remove');
                                $icon.attr('title', 'Awaiting Approval');
                                $actions.find('.not-editing').css('display', 'inherit');
                                $insult.attr('data-insult', value);
                                $insult.empty().text(value.replace(/<NICK>/g, handle));
                            } else {
                                $input.removeAttr('disabled');
                                $actions.find('.editing').removeAttr('disabled').css('display', 'none');
                                $actions.find('.not-editing').css('display', 'inherit');
                                $insult.empty().text(insult.replace(/<NICK>/g, handle));
                            }
                        });
                    } else {
                        $actions.find('.editing').css('display', 'none');
                        $actions.find('.not-editing').css('display', 'inherit');
                        $insult.empty().text(insult.replace(/<NICK>/g, handle));
                    }
                }
            });
            $insult.empty().append($form);
			$insult.find('input').focus().select();
		});
		$(this).find('.cancel').click(function () {
			var $actions = $(this).parent(),
				$insult = $actions.parent().find('td.insult'),
				insult = $insult.data('insult'),
                handle = $insults.data('handle');
			$actions.find('.editing').css('display', 'none');
			$actions.find('.not-editing').css('display', 'inherit');
			$insult.empty().text(insult.replace(/<NICK>/g, handle));
		});
		$(this).find('.save').click(function () {
            var $actions = $(this).parent(),
                $insult = $actions.parent().find('td.insult'),
                $form = $insult.find('form');
            $form.submit();
		});
        $(this).find('.delete').click(function () {
            var $actions = $(this).parent(),
                $row = $actions.parent(),
                $insult = $actions.parent().find('td.insult'),
                insult = $insult.data('insult'),
                insultId = $insult.parent().data('insult-id');
            $delete.off('click').on('click', function () {
                $delete.attr('disabled','');
                $.post('/~chances/insults/insult/' + insultId + '/delete', function (response) {
                    response = JSON.parse(response);
                    $deleteDialog.modal('hide');
                    $delete.removeAttr('disabled');
                    if (response.success === true) {
                        $row.remove();
                    }
                });
            });
        });
	});
});
