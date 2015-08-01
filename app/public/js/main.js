jQuery(function ($) {

  doVisible();

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
      doVisible();
    });
  });

  function doVisible() {
    setTimeout(function () {
      $('.result-image-container:not(.visible)').each(function (i, item) {
        $(item).addClass('visible');
      });
    }, 100);
  }
});