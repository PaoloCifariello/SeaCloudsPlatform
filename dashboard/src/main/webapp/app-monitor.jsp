<%@ page import="eu.seaclouds.platform.dashboard.ConfigParameters" %>
<%@ page import="brooklyn.rest.client.BrooklynApi" %>
<%@ page import="brooklyn.rest.domain.ApplicationSummary" %>
<%@ page import="brooklyn.rest.domain.EntitySummary" %>
<%@ page import="java.util.List" %>
<%@ page import="brooklyn.rest.domain.SensorSummary" %>


<!DOCTYPE html>
<html>

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SeaClouds Monitoring GUI - Monitor View</title>

    <!-- Core CSS - Include with every page -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/font-awesome.min.css" rel="stylesheet">


    <!-- SB Admin CSS - Include with every page -->
    <link href="css/sb-admin.css" rel="stylesheet">

    <%! final BrooklynApi BROOKLKYN_API = new BrooklynApi(ConfigParameters.DEPLOYER_ENDPOINT); %>
</head>

<body>

<div id="wrapper">

    <nav class="navbar navbar-default navbar-fixed-top" role="navigation"
         style="margin-bottom: 0">
        <div class="navbar-header">
            <a class="navbar-brand extrnLink"
               href="http://www.seaclouds-project.eu/"> <img
                    class="img-responsive " src="img/seaclouds-header.png"
                    style="max-width: 100px; margin-top: -18px;">
            </a>
            <button type="button" class="navbar-toggle" data-toggle="collapse"
                    data-target=".sidebar-collapse">
                <span class="sr-only">Toggle navigation</span> <span
                    class="icon-bar"></span> <span class="icon-bar"></span> <span
                    class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="index.html">SeaClouds Monitoring
                GUI</a>
        </div>
        <!-- /.navbar-header -->

        <!-- TODO: Get alert number from Monitoring API -->
        <ul class="nav navbar-top-links navbar-right">
            <li id="loading-spinner"></li>
            <li class="dropdown"><a class="dropdown-toggle"
                                    data-toggle="dropdown" href="#"><span class="badge">0</span><i
                    class="fa fa-bell fa-fw"></i> <i class="fa fa-caret-down"></i> </a>
                <ul class="dropdown-menu dropdown-alerts">
                    <li><a href="#">
                        <div>
                            <i class="fa fa-exclamation fa-fw"></i>This feature will be
                            available in prior releases<span
                                class="pull-right text-muted small">Just now</span>
                        </div>
                    </a></li>
                    <li class="divider"></li>

                    <!-- TODO: Open all alerts page -->
                    <li class="disabled"><a class="text-center" href="#"> <strong>See
                        All Alerts</strong> <i class="fa fa-angle-right"></i>
                    </a></li>
                </ul>
                <!-- /.dropdown-alerts --></li>
            <!-- /.dropdown -->
            <li class="dropdown"><a class="dropdown-toggle"
                                    data-toggle="dropdown" href="#"> <i class="fa fa-user fa-fw"></i>
                <i class="fa fa-caret-down"></i>
            </a>
                <ul class="dropdown-menu dropdown-user">
                    <li class="disabled"><a href="#"><i
                            class="fa fa-user fa-fw"></i>User Profile</a></li>
                    <li class="disabled"><a href="#"><i
                            class="fa fa-gear fa-fw"></i>Settings</a></li>
                    <li class="divider"></li>
                    <li><a href="#"><i class="fa fa-exclamation fa-fw"></i>
                        This feature will be available in prior releases</a></li>
                </ul>
                <!-- /.dropdown-user --></li>
            <!-- /.dropdown -->
        </ul>
        <!-- /.navbar-top-links -->
    </nav>

    <div id="page-wrapper-no-sidebar">
        <div class="row">
                <div class="col-lg-12">
                <h1 class="page-header">
                    Live Monitor
                    <small> Available application metrics
                    </small>
                </h1>
            </div>
            <!-- /.col-lg-12 -->
        </div>

        <div class="row" id="page-content">
            <div class="col-lg-12">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <strong>Live metrics selector</strong>
                        <a data-toggle="collapse" data-parent="#accordion" data-target ="#app-status-collapsable">
                            <i class="fa fa-chevron-down"></i>
                        </a>
                    </div>
                    <div class="panel-collapse collapse in" id="app-status-collapsable" >
                    <div class="panel-body" >
                        <form>

                            <%
                                String appId =  request.getParameter("id");
                                if(appId != null){
                                   for(EntitySummary entitySummary : BROOKLKYN_API.getEntityApi().list(appId)){
                            %>
                                <table class="table">
                                    <caption><strong><%= entitySummary.getName() %> </strong></caption>
                                    <thead>
                                        <tr>
                                            <th>Name</th>
                                            <th>Description</th>
                                            <th>Selected</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                        <%
                                            for (SensorSummary sensorSummary : BROOKLKYN_API.getSensorApi().list(appId, entitySummary.getId())) {
                                        %>

                                        <tr>
                                            <td><%=sensorSummary.getName()%></td>
                                            <td><%=sensorSummary.getDescription()%></td>
                                            <td><input type="checkbox" onClick="if (this.checked) { addGraph('<%=appId%>','<%=entitySummary.getId()%>','<%=sensorSummary.getName()%>') } else { removeGraph('<%=appId%>','<%=entitySummary.getId()%>','<%=sensorSummary.getName()%>') }"></td>
                                        </tr>

                                        <%
                                            }
                                        %>
                                    </tbody>
                           <%
                                    }
                                }
                           %>


                            </table>
                        </form>
                    </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row" id="page-graphs">

        </div>
    </div>
    <!-- /#page-wrapper -->

</div>
<!-- /#wrapper -->

<!-- Core Scripts - Include with every page -->
<script src="js/lib/jquery-1.10.2.js"></script>
<script src="js/lib/jquery.metisMenu.js"></script>
<script src="js/lib/bootstrap.min.js"></script>
<script src="js/lib/spin.min.js"></script>

<!-- SB Admin Scripts - Include with every page -->
<script src="js/sb-admin.js"></script>

<!-- SeaClouds configuration constants -->
<script src="js/config.js"></script>


<!-- Page-Level Plugin Scripts - Flot -->
<script src="js/lib/jquery.flot.js"></script>
<script src="js/lib/jquery.flot.autoscale.js"></script>


<!-- Swagger JS API -->
<script src='js/lib/swagger.js' type='text/javascript'></script>
<script type="text/javascript">
var SPINNER = new Spinner({lines: 13, length: 6, width: 2, radius: 5, top: "-5px"}).spin(document.getElementById("loading-spinner"));
var APP_ID = location.search.split('id=')[1];
var CONTENT_ID = "page-content";
var ACTIVE_API_CALLS = [];

// Configuring API connection and GUI loading
var API = new SwaggerApi({
    basePath: BROOKLYN_ENDPOINT,
    discoveryUrl: BROOKLYN_ENDPOINT + "/v1/apidoc",
    success: apiLoaded,
    fail: apiLoadFailed
});

var BACKEND_READY = false;

function checkBackendStatus(){
    if(!API.ready){
        $('#' + CONTENT_ID).html("<h1 class=\"text-center text-danger\">Unable to find any deployer engine</h1>")
    }else if(!APP_ID){
        $('#' + CONTENT_ID).html("<h1 class=\"text-center text-danger\">Missing Application ID</h1>")
    }else{
        API.Applications.get({application:APP_ID}, undefined, function(){
            $('#' + CONTENT_ID).html("<h1 class=\"text-center text-danger\">Invalid Application ID</h1>");
            BACKEND_READY = false;
        });
    }

    BACKEND_READY = !API.ready || APP_ID != undefined;
}


function apiLoaded() {
    // Check API Connection readiness
    checkBackendStatus();

    if (BACKEND_READY) {
        //FIXME: HACKY WAY TO ACCESS SENSOR API
        API.SensorAPI = API['Entity Sensors'];
    }

    SPINNER.stop();
}

function apiLoadFailed(err) {

    $('#' + CONTENT_ID).html("<h1 class=\"text-center text-danger\">Unable to find any deployer engine</h1>")
    SPINNER.stop();
}


function addGraph(appId, entityId, sensorName){
    $('#page-graphs').append(generateSensorPanel(appId, entityId, sensorName));
    setupGraphs("#flot-line-chart-" + appId + "-" + entityId + "-" + sensorName, entityId, sensorName);
    $('#app-status-collapsable').collapse('hide')


}

function removeGraph(appId, entityId, sensorName){
    $(escapeDots("#panel-container-" + appId +'-' + entityId + '-' + sensorName)).remove();
    $('#app-status-collapsable').collapse('hide')

    for (var i = 0; i < ACTIVE_API_CALLS.length; i++) {
        if (ACTIVE_API_CALLS[i].functionName == appId +'-' + entityId + '-' + sensorName) {
            clearInterval(ACTIVE_API_CALLS[i].programedFunction);
            ACTIVE_API_CALLS.splice(i--, 1);
        }
    }

}



function generateSensorPanel(appId, entityId, sensorName){

    var panelHeading = "<div class=\"col-lg-6\" id=\"panel-container-" + appId + "-" + entityId + "-" + sensorName + "\"" + "><div class=\"panel panel-default\">";
    panelHeading +=  "<div class=\"panel-heading\"><i class=\"fa fa-bar-chart-o fa-fw\"></i> " + entityId + ", " + sensorName +"</div>";


    var panelBody = "<div class=\"panel-body\">";


    panelBody +=  "<div class=\"flot-chart\"><div class=\"flot-chart-content\" id=\"flot-line-chart-"+ appId + "-" + entityId + "-" + sensorName +"\"></div></div>";
    panelBody += "</div></div>";

    return  panelHeading + panelBody;

}


function setupGraphs (containerID, entityID, sensorName) {

    var container = $(escapeDots(containerID));

    series = [
        {

            lines: {
                fill: true
            }
        }
    ];

    //

    var plot = $.plot(container, series, {
        grid: {
            borderWidth: 1,
            minBorderMargin: 25,
            labelMargin: 10,
            backgroundColor: {
                colors: ["#fff", "#e4f4f4"]
            },

            markings: function (axes) {
                var markings = [];
                var xaxis = axes.xaxis;
                for (var x = Math.floor(xaxis.min); x < xaxis.max; x += xaxis.tickSize * 2) {
                    markings.push({
                        xaxis: {
                            from: x,
                            to: x + xaxis.tickSize
                        },
                        color: "rgba(232, 232, 255, 0.2)"
                    });
                }
                return markings;
            }
        },
        xaxis: {
            tickFormatter: function () {
                return "";
            }
        },
        yaxis: {
            min :0,
            ticks:10,
            alignTicksWithAxis: 1
        },
        legend: {
            show: true
        }
    });


    var data = [];
    var MAXIMUM = container.outerWidth() / 2 || 300;


    // Programming updates
    function updateFunction(apiResponse){
        var value = apiResponse;


        data.push(value);

        if (data.length >= MAXIMUM){
            data.shift();
        }

        var graphPoints = [];
        for (var i = 0; i < data.length; ++i) {
            graphPoints.push([i, data[i]])
        }

        series[0].data = graphPoints;
        plot.setData(series);
        plot.autoScale();
        plot.draw();


    }

    var programedInterval = setInterval(function(){
        API.SensorAPI.get({application:APP_ID, entity:entityID, sensor:sensorName}, updateFunction)
    }, 40);

    ACTIVE_API_CALLS.push({
        functionName: APP_ID + "-" + entityID + "-" + sensorName,
        programedFunction : programedInterval
    });
}



function escapeDots( myid ) {

    return myid.replace( /(:|\.|\[|\])/g, "\\$1" );

}

</script>
</body>


</html>