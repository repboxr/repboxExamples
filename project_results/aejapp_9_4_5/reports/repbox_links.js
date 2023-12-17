var last_highlight = '';

$(document).ready(function() {
  $(document).on("click",".tabnum",function(event) {
    let el = event.currentTarget;
    let id = el.id;
    // cell_5
    let cellid =  parseInt(id.substring(5));
    let runid = cellid_to_runid[cellid-1];

    let code_el = $("#runid-"+runid);
    let td_el = $(code_el).closest("td");
    //let cmd_el = $(td_el).find(".reg-cmd");
    let cmd_el = $(td_el).find("code").first();


    // 'L4___1'
    let cmd_id = $(cmd_el).attr("id");

    let sep_pos = cmd_id.indexOf("___");
    let donum = parseInt(cmd_id.substring(sep_pos+3));
    let line = parseInt(cmd_id.substring(1,sep_pos));

    let tablink = "#dotab_"+donum;
    $('#dotabs a[href="'+tablink+'"]').tab('show');
    if (last_highlight !== '') {
      $(last_highlight).removeClass("code-highlight");
    }
    $(cmd_el).addClass("code-highlight");
    last_highlight = "#"+cmd_id;
    let showline = parseInt(line)-3;
    if (showline < 1) showline = 1;
    document.querySelector("#B"+showline+"___"+donum).scrollIntoView({
      behavior: 'smooth'
    });
  });
});


function set_do_tab(donum, line) {
  tablink = "#dotab_"+donum;
  $('#dotabs a[href="'+tablink+'"]').tab('show');
  if (line !== undefined) {
    showline = parseInt(line)-3;
    if (showline < 1) showline = 1;
    if (last_highlight !== '') {
      $(last_highlight).removeClass("code-highlight");
    }
    $("#L"+line+"___"+donum).addClass("code-highlight");
    last_highlight = "#L"+line+"___"+donum;
    document.querySelector("#L"+showline+"___"+donum).scrollIntoView({
      behavior: 'smooth'
    });
  }
}



const urlpar = new URLSearchParams(window.location.search);

if (urlpar.has('do')) {
  dopar = urlpar.get('do');
  tablink = "#dotab_"+dopar;
  $('.nav-tabs a[href="'+tablink+'"]').tab('show');

  if (urlpar.has('L')) {
    linepar = urlpar.get('L');
    lineid = "#L"+linepar+"___"+dopar;
    $(lineid).addClass("code-highlight");
    document.querySelector(lineid).scrollIntoView({
      behavior: 'smooth'
    });
    //window.scroll(0,findPos(document.getElementById("L"+linepar+"___"+dopar)));
  }
}

