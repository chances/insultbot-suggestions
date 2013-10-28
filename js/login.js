/**
 * Created with JetBrains RubyMine.
 * User: chances
 * Date: 10/28/13
 * Time: 2:22 AM
 */
$(function () {
    $('.alert-dismissable').each(function () {
        var $alert = $(this);
        $alert.find('.close').click(function () {
            $('#' + $(this).attr('data-dismiss')).fadeOut('fast');
            $('#username').focus();
        });
    });
});