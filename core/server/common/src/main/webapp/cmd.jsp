<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--

    The Alluxio Open Foundation licenses this work under the Apache License, version 2.0
    (the "License"). You may not use this work except in compliance with the License, which is
    availabsle at www.apache.org/licenses/LICENSE-2.0

    This software is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
    either express or implied, as more fully set forth in the License.

    See the NOTICE file distributed with this work for information regarding copyright ownership.

--%>

<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <jsp:include page="header-links.jsp"/>
</head>
<title>Command Line Interface</title>
<body>
<jsp:include page="header-scripts.jsp"/>
<div class="container-fluid" id="app">
    <jsp:include page="/header"/>


    <div class="row-fluid">
        <div class="row-fluid">
            <div class="span12 well">
                <h1 class="text-error">
                    <%= request.getAttribute("fatalError") %>
                </h1>

                <div>
                    <div class="control-group">
                        <label for="txtCmd" class="control-label">Execute command, submit by enter:</label>
                        <div class="controls">
                            <input type="text" id="txtCmd" placeholder="ls /">
                            <button class="btn btn-success" onclick="sendCmd()">Send</button>
                            <i class="fa fa-spinner fa-spin" id="spinner" style="font-size:24px"></i>
                        </div>
                    </div>
                    <a class="btn btn-primary" data-toggle="collapse" href="#commandExample" role="button"
                       aria-expanded="false"
                       aria-controls="commandExample">
                        Command Example
                    </a>
                    <div class="collapse" id="commandExample">
                        <table>
                            <tr>
                                <td><a href="#cat" id="markdown-toc-cat">cat</a></td>
                                <td><a href="#checkconsistency" id="markdown-toc-checkconsistency">checkConsistency</a>
                                </td>
                                <td><a href="#checksum" id="markdown-toc-checksum">checksum</a></td>
                                <td><a href="#chgrp" id="markdown-toc-chgrp">chgrp</a></td>
                            </tr>
                            <tr>
                                <td><a href="#chmod" id="markdown-toc-chmod">chmod</a></td>
                                <td><a href="#chown" id="markdown-toc-chown">chown</a></td>
                                <td><a href="#copyfromlocal" id="markdown-toc-copyfromlocal">copyFromLocal</a></td>
                                <td><a href="#copytolocal" id="markdown-toc-copytolocal">copyToLocal</a></td>
                            </tr>
                            <tr>
                                <td><a href="#count" id="markdown-toc-count">count</a></td>
                                <td><a href="#cp" id="markdown-toc-cp">cp</a></td>
                                <td><a href="#du" id="markdown-toc-du">du</a></td>
                                <td><a href="#fileinfo" id="markdown-toc-fileinfo">fileInfo</a></td>
                            </tr>

                            <tr>
                                <td><a href="#free" id="markdown-toc-free">free</a></td>
                                <td><a href="#getcapacitybytes" id="markdown-toc-getcapacitybytes">getCapacityBytes</a>
                                </td>
                                <td><a href="#getusedbytes" id="markdown-toc-getusedbytes">getUsedBytes</a></td>
                                <td><a href="#help" id="markdown-toc-help">help</a></td>
                            </tr>
                            <tr>
                                <td><a href="#leader" id="markdown-toc-leader">leader</a></td>
                                <td><a href="#load" id="markdown-toc-load">load</a></td>
                                <td><a href="#loadmetadata" id="markdown-toc-loadmetadata">loadMetadata</a></td>
                                <td><a href="#location" id="markdown-toc-location">location</a></td>
                            </tr>
                            <tr>
                                <td><a href="#ls" id="markdown-toc-ls">ls</a></td>
                                <td><a href="#masterinfo" id="markdown-toc-masterinfo">masterInfo</a></td>
                                <td><a href="#mkdir" id="markdown-toc-mkdir">mkdir</a></td>
                                <td><a href="#mount" id="markdown-toc-mount">mount</a></td>
                            </tr>

                            <tr>
                                <td><a href="#mv" id="markdown-toc-mv">mv</a></td>
                                <td><a href="#persist" id="markdown-toc-persist">persist</a></td>
                                <td><a href="#pin" id="markdown-toc-pin">pin</a></td>
                                <td><a href="#report" id="markdown-toc-report">report</a></td>
                            </tr>

                            <tr>
                                <td><a href="#rm" id="markdown-toc-rm">rm</a></td>
                                <td><a href="#setttl" id="markdown-toc-setttl">setTtl</a></td>
                                <td><a href="#stat" id="markdown-toc-stat">stat</a></td>
                                <td><a href="#tail" id="markdown-toc-tail">tail</a></td>
                            </tr>
                            <tr>
                                <td><a href="#test" id="markdown-toc-test">test</a></td>
                                <td><a href="#touch" id="markdown-toc-touch">touch</a></td>
                                <td><a href="#unmount" id="markdown-toc-unmount">unmount</a></td>
                                <td><a href="#unpin" id="markdown-toc-unpin">unpin</a></td>
                            </tr>
                            <tr>
                                <td><a href="#unsetttl" id="markdown-toc-unsetttl">unsetTtl</a></td>
                            </tr>
                        </table>

                    </div>

                    <hr>
                    <div style="height: 500px; overflow-y: scroll;" id="divOutput">
                        <p>Output:</p>
                        <pre class="prettyprint linenums" id="preOutput"></pre>
                    </div>
                </div>

                <!-- pagination component -->
                <div class="pagination pagination-centered">
                    <ul id="paginationUl">
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <style>
        #txtCmd {
            font-family: Monaco, Menlo, Consolas, "Courier New", monospace;
            width: 600px;
        }

        td {
            padding: 5px;
        }
    </style>
    <script>
        $("#spinner").hide();

        $("#txtCmd").on("keyup", function (event) {
            if (event.keyCode === 13) {
                sendCmd();
            }
        });

        function sendCmd() {
            $("#spinner").show();
            var cmd = $("#txtCmd").val();
            $("#preOutput").append("<b>$ " + cmd + "</b>\n");
            $.ajax({
                url: "/cmd",
                data: {"cmd": cmd},
                type: "POST",
                dataType: "text",
                success: function (data) {
                    $("#preOutput").append(data + "\n");
                    $('#divOutput').scrollTop($('#divOutput')[0].scrollHeight);
                },
                error: function (xhr, status, error) {
                    alert(status);
                    alert(error);
                },
                complete: function () {
                    $("#spinner").hide();
                    $("#txtCmd").val("");
                }
            });
        }
    </script>
    <%@ include file="footer.jsp" %>
</div>

</body>
</html>
