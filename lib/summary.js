var summary = {};

$(function(){


summary.init = function(d){
  var table = $('<table>');
  $.map(d.header, function(v, k){
    table.append($('<tr>').append($('<td>').html(k)).append($('<td>').html(v)));
  });
  $('#summary').append($('<div id="summary-header">').append(table));
};



});
