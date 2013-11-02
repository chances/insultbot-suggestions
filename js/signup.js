/**
 * Created with JetBrains RubyMine.
 * User: Chance Snow
 * Date: 10/28/13
 * Time: 3:43 PM
 */
$(function () {
    var $signup = $('#signup'),
    	$signupPanel = $('#signupPanel'),
        $errorMsg = $('#error'),
        $username = $('#username'),
        $password = $('#password'),
        $authError = $('#authError'),
        $error = $errorMsg.parent();

    console.log($authError.size());
    if ($authError.size()) {
    	$signupPanel.removeClass('center-vert');
    	$username.focus().parent().addClass('has-error');
    	$password.parent().addClass('has-error');
    }
    $error.hide();

    $signup.submit(function (event) {
        //Remove error from form
    	$signup.removeClass('has-error');
        $signup.find('.form-group').removeClass('has-error');
        if ($signupPanel.hasClass('center-vert') === false) {
            $signupPanel.addClass('center-vert');
        }
        $authError.remove();
        vals = {};
        vals['u'] = $username.val().replace(/\s+/g, '');
        vals['p'] = $password.val().replace(/\s+/g, '');
        //Check for errors
        if (!vals['u'] || !vals['p']) {
            //Formulate error message
            var message = "";
            if (!vals['u'] && vals['p']) {
                message = "a username";
                $username.focus().parent().addClass('has-error');
            } else if (vals['u'] && !vals['p']) {
                message = "a password";
                $password.focus().parent().addClass('has-error');
            } else if (!vals['u'] && !vals['p']) {
                message = "a username and password";
                $username.focus().parent().addClass('has-error');
                $password.parent().addClass('has-error');
            }

            $signupPanel.addClass('animated shake').removeClass('center-vert');
        	window.setTimeout(function () {
        		$signupPanel.removeClass('animated shake');
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