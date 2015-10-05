function createSVG(tag, attrs) {
    var el= document.createElementNS('http://www.w3.org/2000/svg', tag);
    for(var k in attrs)
      el.setAttribute(k, attrs[k]);
    return el;
}

$(function(){

$('#labels >span[href]').click(function(){
  var href = $(this).attr('href').slice(1);
  // class label-acting
  $('#labels >span[href]').map(function(){$(this).removeClass('label-acting');});
  $(this).addClass('label-acting');
  // panels
  $('#panels >div').hide();
  $('#'+href).show();
  // buttons
  $('#label-btns >span').hide();
  $('#label-btns >span[belong='+href+']').show();
  // end
  $(this).blur();
  return false;
});

// $('#labels >span:first').click();
$('#labels >span[href="#flow"]').click();

var blank_textarea = function(){
  return $('<div class="blank-textarea"></div>')
    .append($('<textarea>'))
    .keydown(function(e){
      if(e.which == 27)
        $(this).remove();
    })
    .draggable()
    .css('position','absolute')
    .css('top','20%')
    .css('left','30%');
};

$('#label-btns >span')
  .append(
    $('<span class="label-btn">note</span>')
      .click(function(){
        $('#'+$(this).parent().attr('belong')).append(blank_textarea());
      }));

$('#flow').append($('<svg id="flow-svg" width="'+
  ($('#flow').width()-10)+'" height="'+($('#flow').height()-10)+'"></svg>'));

$('#panels').scroll(function(){
  $('#flow-svg')
    .attr('height', ($(this).height()+$(this).scrollTop()).toString())
    .attr('width', ($(this).width()+$(this).scrollLeft()).toString());
});

// var l = createSVG('line', {x1: 0, x2: 50, y1: 0, y2: 100, stroke: 'red', 'stroke-width': 2});
// $('#flow-svg').append(l);


});
