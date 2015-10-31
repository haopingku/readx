var flow = {};

$(function(){

var count_left = function(d){
  return d.position().left + $('#flow').scrollLeft() + d.outerWidth() / 2;
};
var count_top = function(d, i){
  return d.position().top + $('#flow').scrollTop() + i * d.outerHeight();
};

flow.init = function(d){
  if(d.flows){
    // create svg
    var width = $('#flow').width() - 10, height = $('#flow').height() - 10;
    var svg = $('<svg id="flow-svg" width="'+width+'" height="'+height+'"></svg>');
    $('#flow').append(svg);
  }
  
  if(d.instructions){
    // resize svg when panel is resized
    $('#flow').scroll(function(){
      $('#flow-svg')
        .attr('height', $(this).height()+$(this).scrollTop())
        .attr('width', $(this).width()+$(this).scrollLeft()-10);
    });
    
    // create instruction blocks
    var blocks = $.map(d.instructions, function(v, i){
      return create_insts_block(v);
    });
    
    // call instruction, scroll
    $('.flow-inst-code-disas-call').click(function(){
      var addr = $('#'+$(this).attr('href'));
      $('#flow').animate({
        scrollTop: addr.parent().parent().parent().parent().css('top')
      }, 300);
      var color = addr.css('color');
      for(var i=0; i<2; i++){
        addr.animate({color: 'white'}, 450);
        addr.animate({color: color}, 450);
      }
    });
  }
  
  // wait a small time for the rendering of div to get its size and position
  setTimeout(function(){
    if(d.instructions)
      set_insts_block_top(blocks);
    if(d.flows)
      create_flows(d);
  }, 5);
  
};

var create_insts_block = function(v, h){
  var sec = v.sec + (v.sym ? (' &lt;'+v.sym+'&gt;') : '');
  var syntax_colorize = function(s){
    s = s || '';
    var c = 'flow-inst-code-disas';
    if(m = s.match(/^([0-9a-f]+) <(.+?)>$/)){
      return '<span class="'+c+'-call" href="flow-inst-addr' +
        m[1] + '">' + m[1] + ' &lt;' + m[2] + '&gt;</span>';
    } else {
      return s
        .replace(/(%\w+)/g, '<span class="'+c+'-reg">$1</span>')
        .replace(/((\$)-?(?:0x)?[a-f0-9]+)/i,
          '<span class="'+c+'-imm">$1</span>')
        .replace(/^((?:0x)?[a-f0-9]+),/i,
          '<span class="'+c+'-num">$1</span>,');
      // /(?:\b|^)((?:-)?(?:\$)?0x[a-f0-9]+)(?:\b|$)/ig,
      // '<span class="flow-inst-code-disas-num">$1</span>');
    }
  };
  var div = $('<div id="flow-inst-'+v.id+'" class="flow-inst-block">');
  var button = {
    note: $('<span class="flow-inst-btn">note</span>')
      .click(function(){
        var t = $('<input type="text">')
          .keydown(function(e){
            if(e.which == 27)
              $(this).remove();
          });
        div.append($('<div>').append(t));
      }),
    hex: $('<span class="flow-inst-btn">hex</span>')
      .click(function(){
        this.d = this.d || 1;
        if(this.d % 2 == 1)
          div.find('.flow-inst-code-hex').show();
        else
          div.find('.flow-inst-code-hex').hide();
        this.d += 1;
      }),
    wrap: $('<span class="flow-inst-btn">wrap</span>')
      .click(function(){
        this.d = this.d || 1;
        if(this.d % 2 == 1)
          div.find('tr:nth-child(n+2)').hide();
        else
          div.find('tr:nth-child(n+2)').show();
        this.d += 1;
      })
  }
  div.append('<div class="flow-inst-code-sec">'+sec+'</div>')
    .append(
      $('<div>').append(button.note).append(button.hex).append(button.wrap))
    .draggable()
    .css('position','absolute')
    .css('left', '30%')
    .mousedown(function(){$(this).css('z-index', (z_index += 1));});
  $('#flow').append(div);
  
  var table = $('<table class="flow-inst-code-table">');
  $.map(v.code, function(c,i){
    tr = $('<tr>');
    tr.append(
      '<td id="flow-inst-addr-'+c[0].toString(16)+'" class="flow-inst-code-addr">'+
        c[0].toString(16)+
        '</td>')
      .append(
        '<td class="flow-inst-code-hex">'+
        $.map(c[1], function(_){
          return (_ < 16 ? '0' : '') + _.toString(16);
        }).join(' ')+
        '</td>')
      .append('<td class="flow-inst-code-disas">'+c[2]+'</td>')
      .append('<td class="flow-inst-code-disas">'+syntax_colorize(c[3])+'</td>');
    table.append(tr);
  });
  $('#flow').append(div.append(table));
  div.hide(); // hide for rendering, show in set_insts_block_top()
  return div;
};
var set_insts_block_top = function(blocks){
  var h = 10;
  $.map(blocks, function(v){
    v.css('top', ''+h+'px');
    h += v.height() + 40;
  });
  $('.flow-inst-block').show();
};
var create_flows = function(d){
  $.map(d.flows, function(v,i){
    var src = $('#flow-inst-'+v[0]), tar = $('#flow-inst-'+v[1]);
    if(src.length == 0 || tar.length == 0)
      return;
    var color = (v[2] == 'jmp_succ' ? '#FD4B4B' : 'green');
    $('#flow-svg')
      .append(
        createSVG('line', {
          id: 'inst-line-'+i,
          x1: count_left(src, 1),
          x2: count_left(tar, 0),
          y1: count_top(src, 1),
          y2: count_top(tar, 0),
          stroke: color,
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
