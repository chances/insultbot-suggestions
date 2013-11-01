/**
 * Created with JetBrains RubyMine.
 * User: Chance Snow
 * Date: 10/28/13
 * Time: 2:22 AM
 */
$(function () {
    var $login = $('#login'),
    	$loginPanel = $('#loginPanel'),
        $username = $('#username'),
        $password = $('#password');

    $('.alert-dismissable').each(function () {
        var $alert = $(this);
        $alert.find('.close').click(function () {
            $('#' + $(this).attr('data-dismiss')).fadeOut('fast');
            $username.focus();
        });
    });

    var $errorMsg = $('#errorMsg'),
        $error = $errorMsg.parent();

    $error.hide();

    $login.submit(function (event) {
        //Remove error from form
    	$login.removeClass('has-error');
        $login.find('.form-group').removeClass('has-error');
        vals = {};
        vals['u'] = $username.val().replace(/\s+/g, '');
        vals['p'] = $password.val().replace(/\s+/g, '');
        //Check for errors
        if (!vals['u'] || !vals['p']) {
            //Formulate error message
            var message = "";
            if (!vals['u'] && vals['p']) {
                message = "a username or email address";
                $username.focus().parent().addClass('has-error');
            } else if (vals['u'] && !vals['p']) {
                message = "a password";
                $password.focus().parent().addClass('has-error');
            } else if (!vals['u'] && !vals['p']) {
                message = "all fields";
                $username.focus().parent().addClass('has-error');
                $password.parent().addClass('has-error');
            }

            $loginPanel.addClass('animated shake');
        	window.setTimeout(function () {
        		$loginPanel.removeClass('animated shake');
        	}, 1000);
            //Show error message
            if ($error.is(':hidden')) { $error.show(); }
            $errorMsg.text(message);
            event.preventDefault();
        } else {
            $error.hide();
        }
    });
});