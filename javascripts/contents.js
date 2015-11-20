var contents = {};

$(function(){

contents.init = function(d){
  if(d.contents){
    var table = $('<table>');
    $.map(d.contents, function(v){
      var tr = $('<tr>'),
          td = $('<td class="section" colspan="3">'+v[0]+'</td>');
      table.append(tr.append(td));
      var adr = [], hex = [], chr = [];
      $.map(v[1], function(v_){
        adr.push(v_[0]);
        hex.push(v_[1]);
        chr.push(v_[2].replace(' ','&nbsp;'));
      });
      var tr = $('<tr>');
      tr.append($('<td>').html(adr.join('<br>')))
        .append($('<td>').html(hex.join('<br>')))
        .append($('<td>').html(chr.join('<br>')));
      table.append(tr);
    });
    $('#contents').append(table);
  }
};


});
