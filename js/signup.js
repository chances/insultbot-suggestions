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
        $email = $('#email'),
        $password = $('#password'),
        $error = $errorMsg.parent();

    $error.hide();

    $signup.submit(function (event) {
        //Remove error from form
    	$signup.removeClass('has-error');
        $signup.find('.form-group').removeClass('has-error');
        $signupPanel.addClass('center-vert');
        vals = {};
        vals['u'] = $username.val().replace(/\s+/g, '');
        vals['e'] = $email.val().replace(/\s+/g, '');
        vals['p'] = $password.val().replace(/\s+/g, '');
        console.log(vals);
        //Check for errors
        if (!vals['u'] || !vals['e'] || !vals['p']) {
            //Formulate error message
            var message = "";
            if (!vals['u'] && !vals['e'] && vals['p']) {
                message = "a username and an email address";
                $username.focus().parent().addClass('has-error');
                $email.parent().addClass('has-error');
            } else if (!vals['u'] && vals['e'] && vals['p']) {
                message = "a username";
                $username.focus().parent().addClass('has-error');
            } else if (vals['u'] && !vals['e'] && !vals['p']) {
                message = "an email address and password";
                $email.focus().parent().addClass('has-error');
                $password.parent().addClass('has-error');
            } else if (vals['u'] && vals['e'] && !vals['p']) {
                message = "a password";
                $password.focus().parent().addClass('has-error');
            } else if (vals['u'] && !vals['e'] && !vals['p']) {
                message = "an email address and a password";
                $email.focus().parent().addClass('has-error');
                $password.parent().addClass('has-error');
            } else if (vals['u'] && !vals['e'] && vals['p']) {
                message = "an email address";
                $email.focus().parent().addClass('has-error');
            } else if (!vals['u'] && vals['e'] && vals['p']) {
                message = "a username and a password";
                $username.focus().parent().addClass('has-error');
                $password.parent().addClass('has-error');
            } else if (vals['u'] && !vals['e'] && vals['p']) {
                message = "a username and a password";
                $username.focus().parent().addClass('has-error');
                $password.parent().addClass('has-error');
            } else if (!vals['u'] && vals['e'] && !vals['p']) {
                message = "a username and password";
                $username.focus().parent().addClass('has-error');
                $password.parent().addClass('has-error');
            } else if (!vals['u'] && !vals['e'] && !vals['p']) {
                message = "all fields";
                $username.focus().parent().addClass('has-error');
                $email.parent().addClass('has-error');
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