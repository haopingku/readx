var z_index = 10;
function createSVG(tag, attrs) {
    var el= document.createElementNS('http://www.w3.org/2000/svg', tag);
    for(var k in attrs)
      el.setAttribute(k, attrs[k]);
    return el;
}
function blank_textarea(parent_){
  var parent = $('#'+parent_), panel = $('#panels');
  var textarea = $('<textarea spellcheck="false" rows="3">')
    .keypress(function(e){
      if(e.keyCode == 13){
        // $(this).attr('rows', $(this).val().split(/\n/).length+1);
      }
    });
  return $('<div class="notepad"></div>')
    .append(textarea)
    .keydown(function(e){if(e.which == 27)$(this).remove();})
    .draggable()
    .css('position','absolute')
    .css('top', parent.scrollTop() + panel.height() * 2 / 10)
    .css('left', parent.scrollLeft() + panel.width() * 6 / 10)
    .css('z-index', (z_index += 1))
    .mousedown(function(){$(this).css('z-index', (z_index += 1));});
};

$(function(){

$('#labels >span[href]').click(function(){
  var href = $(this).attr('href').slice(1);
  if(!this.init){
    eval(href+'.init(readx_data)');
    this.init = true;
  }
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

$('#labels >span[href="#summary"]').click();

$('title').html('readx '+readx_data.file)
$('#label-file').html(readx_data.file);

$('#label-btns >span')
  .append(
    $('<span class="label-btn">note</span>')
      .click(function(){
        $('#'+$(this).parent().attr('belong'))
          .append(blank_textarea($(this).parent().attr('belong')));
  }));


});
