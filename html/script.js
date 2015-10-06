function createSVG(tag, attrs) {
    var el= document.createElementNS('http://www.w3.org/2000/svg', tag);
    for(var k in attrs)
      el.setAttribute(k, attrs[k]);
    return el;
}
var z_index = 10;

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
// $('#labels >span[href="#summary"]').click();

var blank_textarea = function(){
  var panel = $('#panels');
  return $('<div class="blank-textarea"></div>')
    .append($('<textarea>'))
    .keydown(function(e){
      if(e.which == 27)
        $(this).remove();
    })
    .draggable()
    .css('position','absolute')
    .css('top', panel.scrollTop() + panel.height() * 8 / 10)
    .css('left', panel.scrollLeft() + panel.width() * 6 / 10)
    .css('z-index', (z_index += 1))
    .mousedown(function(){
      $(this).css('z-index', (z_index += 1));
    });
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





});
