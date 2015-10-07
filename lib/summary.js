var summary = {};

$(function(){


summary.init = function(d){
  var table = $('<table>');
  $.map(d.header, function(v){
    var tr = $('<tr>');
    $.map(v, function(v_){
      tr.append($('<td>').html(v_));
    });
    table.append(tr);
  });
  $('#summary').append($('<div id="summary-header">').append(table));
};



});
