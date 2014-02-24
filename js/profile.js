/**
 * Created with JetBrains RubyMine.
 * User: chances
 * Date: 2/24/14
 * Time: 3:42 AM
 */
$(function () {
    var $profile = $('#profile'),
        $profilePanel = $('#profilePanel'),
        $alias = $('#alias'),
        $email = $('#email'),
        $error = $('#error');

    $error.hide();

    $profile.submit(function (event) {
        //Remove error from form
        $profile.find('.form-group').removeClass('has-error');

        if (!$email.val().replace(/\s+/g, '')) {
            $profilePanel.addClass('animated shake');
            window.setTimeout(function () {
                $profilePanel.removeClass('animated shake');
            }, 1000);
            $email.focus().parent().addClass('has-error');

            //Show error message
            if ($error.is(':hidden')) { $error.show(); }
            event.preventDefault();
        } else {
            $error.hide();
        }
    });

    //Delete account stuffs
    var $deleteAccountDialog = $('#deleteAccountModal'),
        $deleteAccount = $('#deleteAccount');

    $deleteAccount.on('click', function () {
        $deleteAccountDialog.modal('hide');
        window.location.href = '/~chances/insults/profile/delete';
    });

    //Admin insult list stuffs
    var $insults = $('#insults'),
        $deleteInsultDialog = $('#deleteInsultModal'),
        $deleteInsult = $('#deleteInsult'),
        $deleteInsultCancel = $('#deleteInsultCancel');

    $insults.find('tbody > tr').each(function () {
        $(this).find('.approve').click(function () {
            var $actions = $(this).parent(),
                $row = $actions.parent(),
                insultId = $row.data('insult-id');
            $row.addClass('loading');
            $actions.find('button').attr('disabled','');
            $.getJSON('/~chances/insults/insult/' + insultId + '/approve', function (response) {
                $row.removeClass('loading');
                if (response.success === true) {
                    $row.remove();
                } else {
                    $actions.find('button').removeAttr('disabled');
                }
            });
        });
        $(this).find('.disapprove').click(function () {
            var $actions = $(this).parent(),
                $row = $actions.parent(),
                insultId = $row.data('insult-id');
            $row.addClass('loading');
            $actions.find('button').attr('disabled','');
            $.getJSON('/~chances/insults/insult/' + insultId + '/disapprove', function (response) {
                $row.removeClass('loading');
                if (response.success === true) {
                    $row.remove();
                    if ($insults.find('tbody tr').length === 0) {
                        window.location.reload();
                    }
                } else {
                    $actions.find('button').removeAttr('disabled');
                }
            });
        });
        $(this).find('.delete').click(function () {
            var $actions = $(this).parent(),
                $row = $actions.parent(),
                insultId = $row.data('insult-id');
            $row.addClass('loading');
            $actions.find('button').attr('disabled','');
            $deleteInsult.off('click').on('click', function () {
                $deleteInsultDialog.addClass('loading').find('button').attr('disabled','');
                $.post('/~chances/insults/insult/' + insultId + '/delete', function (response) {
                    response = JSON.parse(response);
                    $deleteInsultDialog.removeClass('loading').modal('hide');
                    if (response.success === true) {
                        $row.remove();
                        if ($insults.find('tbody tr').length === 0) {
                            window.location.reload();
                        }
                    } else {
                        $deleteInsultDialog.find('button').removeAttr('disabled');
                    }
                });
            });
            $deleteInsultCancel.off('click').on('click', function () {
                $row.removeClass('loading');
                $actions.find('button').removeAttr('disabled');
            });
        });
    });
});
