$(".emp_infs").ready(function() {

  if ($(".emp_infs.index").length > 0) {
    $(".area-time-search").on('click', function(e) {
      empInfChartSet(e.target);
    })
  }

  if ($(".emp_infs.grp_index").length > 0) {
    $(".area-time-search").on('click', function(e) {
      grpEmpInfChartSet();
    })

  }

});

function empInfChartSet(that_search) {
  var qcodes = $("#qcodes").val();
  var start = $("#start").val();
  var end = $("#end").val();
  var fct = that_search.dataset['fct'];

  var url = "/factories/" + fct + "/emp_infs/watercms_flow";
  var that_chart = $('#chart-ctn')[0]

  empChartConfig(url, that_chart, start, end, fct, qcodes)
}


function grpEmpInfChartSet() {
  var qcodes = $("#qcodes").val();
  var start = $("#start").val();
  var end = $("#end").val();
  var fct = $("#empmodal-fcts").val();

  var url = "/factories/" + fct + "/emp_infs/watercms_flow";
  var that_chart = $('#chart-ctn')[0]

  empChartConfig(url, that_chart, start, end, fct, qcodes)
}
