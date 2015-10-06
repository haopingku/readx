var x_data;

$(function(){


var insts_block = function(v, h){
  var sec = v.sec + (v.sym ? (' &lt;'+v.sym+'&gt;') : '');
  var syntax_colorize = function(s){
    return (s||'')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/(%\w+)/g, '<span class="flow-inst-code-disas-reg">$1</span>')
      .replace(
        /(?:\b|^)((?:-)?(?:\$)?(?:0x)?[a-f0-9]+)(?:\b|$)/ig,
        '<span class="flow-inst-code-disas-num">$1</span>');
  };
  var div = $('<div id="flow-inst-'+v.id+'" class="flow-inst-block" style="top: '+h+'px">')
    .append('<div class="flow-inst-code-sec">'+sec+'</div>')
    .append(
      $('<div>')
        .append(
          $('<span class="flow-inst-btn">note</span>')
            .click(function(){
              var t = $('<input type="text">')
                .keydown(function(e){
                  if(e.which == 27)
                    $(this).remove();
                });
              div.append($('<div>').append(t));
            }))
        .append(
          $('<span class="flow-inst-btn">hex</span>')
            .click(function(){
              this.d = this.d || 1;
              if(this.d % 2 == 1)
                div.find('.flow-inst-code-hex').show();
              else
                div.find('.flow-inst-code-hex').hide();
              this.d += 1;
            }))
        .append(
          $('<span class="flow-inst-btn">wrap</span>')
            .click(function(){
              this.d = this.d || 1;
              if(this.d % 2 == 1)
                div.find('tr:nth-child(n+2)').hide();
              else
                div.find('tr:nth-child(n+2)').show();
              this.d += 1;
            })))
    .draggable()
    .css('position','absolute')
    .css('left', '30%')
    .mousedown(function(){
      $(this).css('z-index', (z_index += 1));
    });
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
      .append('<td class="flow-inst-code-disas">'+syntax_colorize(c[3])+'</td>');
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
           i * d.outerHeight();
  };
  
  $('#label-fn').html(d.filename);
  
  var table = $('<table id="summary-header-table">');
  $('#summary').append(table);
  $.map(d.header, function(v, k){
    var tr = $('<tr>');
    tr.append($('<td>').html(k)).append($('<td>').html(v));
    table.append(tr);
  });
  
  
  var table = $('<table>');
  $.map(d.contents, function(v){
    var tr = $('<tr>'),
        td = $('<td class="contents-div" colspan="3">'+v[0]+'</td>');
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
  
  var h = 25;
  $.map(d.insts, function(v, i){
    h += insts_block(v, h) + 25;
  });
  $.map(d.flows, function(v,i){
    var src = $('#flow-inst-'+v[0]), tar = $('#flow-inst-'+v[1]);
    if(src.length == 0 || tar.length == 0)
      return;
    $('#flow-svg')
      .append(
        createSVG('line', {
          id: 'inst-line-'+i,
          x1: count_left(src, 1),
          x2: count_left(tar, 0),
          y1: count_top(src, 1),
          y2: count_top(tar, 0),
          stroke: 'green', // color
          'stroke-width': 2
        })
      )
      .append(
        createSVG('circle', {
          id: 'inst-circle-s-'+i,
          cx: count_left(src, 1),
          cy: count_top(src, 1),
          r: '3',
          fill: 'green',
          'stroke-width': 0
        })
      )
      .append(
        createSVG('circle', {
          id: 'inst-circle-t-'+i,
          cx: count_left(tar, 0),
          cy: count_top(tar, 0),
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
