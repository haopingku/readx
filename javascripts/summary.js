var summary = {};

$(function(){

summary.init = function(d){
  var table = $('<table>');
  if(d.attributes){
    $.map(d.attributes, function(v){
      var tr = $('<tr>');
      $.map(v, function(v_){
        tr.append($('<td>').html(v_));
      });
      table.append(tr);
    });
  }
  $('#summary').append($('<div id="summary-attributes">').append(table));
};



});
