var contents = {};

$(function(){

contents.init = function(d){
  var table = $('<table>');
  $.map(d.contents, function(v){
    var tr = $('<tr>'),
        td = $('<td class="section" colspan="3">'+v[0]+'</td>');
    table.append(tr.append(td));
    $.map(v[1], function(v_){
      var tr = $('<tr>');
      tr.append($('<td>').html(v_[0]))
        .append($('<td>').html(v_[1]))
        .append($('<td>').html(v_[2]));
      table.append(tr);
    });
  });
  $('#contents').append(table);
};


});
