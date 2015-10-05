var x_data;

$(function(){


var insts_block = function(v, h){
  var sec = v.sec + (v.sym ? (' <'+v.sym+'>') : '');
  var z_index = 10;
  var colorize = function(s){
    return (s||'')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/(%\w+)/g, '<span class="flow-inst-code-disas-reg">$1</span>')
      .replace(/\b((?:-$)?(?:0x)?[a-f0-9]+)\b/ig,
        '<span class="flow-inst-code-disas-num">$1</span>');
  };
  
  var div = $('<div id="flow-inst-'+v.id+'" class="flow-inst-block" style="top: '+h+'px">')
    .append(
      $('<div class="flow-inst-btn">wrap</div>')
        .click(function(){
          this.d = this.d || 1;
          if(this.d % 2 == 1)
            div.find('tr:nth-child(n+2)').hide();
          else
            div.find('tr:nth-child(n+2)').show();
          this.d += 1;
        }))
    .append(
      $('<div class="flow-inst-btn">note</div>')
        .click(function(){
          var t = $('<input type="text">')
            .keydown(function(e){
              if(e.which == 27)
                $(this).remove();
            });
          div.append($('<div>').append(t));
        }))
    .append('<div class="flow-inst-code-sec">'+sec+'</div>')
    .draggable()
    .css('position','absolute')
    .mousedown(function(){
      $(this).css('z-index', z_index);
      z_index++;
    })
    ;
  var t = $('<table class="flow-inst-code-table">');
  $.map(v.code, function(c,i){
    tr = $('<tr>');
    tr.append('<td class="flow-inst-code-addr">'+c[0].toString(16)+'</td>')
      .append(
        '<td class="flow-inst-code-hex">'+
        $.map(c[1], function(_){
          return (_ < 16 ? '0' : '') + _.toString(16);
        }).join(' ')+
        '</td>')
      .append('<td class="flow-inst-code-disas">'+c[2]+'</td>')
      .append('<td class="flow-inst-code-disas">'+colorize(c[3])+'</td>');
    t.append(tr);
  });
  $('#flow').append(div.append(t));
  return div.outerHeight();
};

x_data = function(d){
  var panels = $('#panels');
  var count_left = function(d, i){
    return d.position().left + panels.scrollLeft() + d.outerWidth() / 2;
  };
  var count_top = function(d, i){
    return d.position().top + panels.scrollTop() +
           i * d.outerHeight() + (i == 1 ? -1 : 1) * 10;
  };
  
  $('#label-fn').html(d.filename);
  
  $('#header').html((d.header||'').replace(/\n/g,'<br>'));
  $('#sections').html((d.sections||'').replace(/\n/g,'<br>'));
  
  var h = 10;
  $.map(d.insts, function(v, i){
    h += insts_block(v, h) + 10;
  });
  $.map(d.insts_lines, function(v,i){
    var src = $('#flow-inst-'+v[0]), tar = $('#flow-inst-'+v[1]);
    $('#flow-svg')
      .append(
        createSVG('line', {
          id: 'inst-line-'+i,
          x1: count_left(src, 1),
          x2: count_left(tar, 0),
          y1: count_top(src, 1),
          y2: count_top(tar, 0),
          stroke: 'green',
          'stroke-width': 1
        })
      )
      .append(
        createSVG('circle', {
          id: 'inst-circle-s-'+i,
          cx: count_left(src, 1),
          cy: count_left(src, 1),
          r: '3',
          fill: 'green',
          'stroke-width': 0
        })
      )
      .append(
        createSVG('circle', {
          id: 'inst-circle-t-'+i,
          cx: count_left(tar, 0),
          cy: count_left(tar, 0),
          r: '3',
          fill: 'green',
          'stroke-width': 0
        })
      );
    src.bind('drag', function(){
      var l = count_left(src, 1), t = count_top(src, 1);
      $('#inst-line-'+i).attr('x1', l).attr('y1', t);
      $('#inst-circle-s-'+i).attr('cx', l).attr('cy', t);
    });
    tar.bind('drag', function(){
      var l = count_left(tar, 0), t = count_top(tar, 0);
      $('#inst-line-'+i).attr('x2', l).attr('y2', t);
      $('#inst-circle-t-'+i).attr('cx', l).attr('cy', t);
    });
  });
  
};

});
