jQuery(function ($) {
  var current_page = 1;
  var $load = $('#load');

  $load.on('click', function () {
    current_page++;

    $.getJSON('/page/' + current_page).done(function (res) {
      var items = res.items;

      if (items.length <= 0) {
        $load.remove();
        return;
      }
      $.each(items, function (i, item) {
        $('#result-container').append(item);
      });
    });
  });
});