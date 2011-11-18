<#assign title="Shiro on GAE Register">
<#assign header="<h1>List <small>users</small></h1>">
<#assign style="substyle.css">

<!DOCTYPE html>
<html lang="en">
<head>
    <#include "inc/_head.ftl">
</head>

<body>

<div class="topbar">
    <div class="topbar-inner">
        <div class="container">
            <a class="brand" href="/index.html">Shiro on GAE</a>
            <ul class="nav">
                <li><a href="/index.html">Home</a></li>
            </ul>
        </div>
    </div>
</div>

<div class="container">

    <div class="content">
        <section>
            <div class="page-header">
                ${header}
            </div>
            <div class = "row">
                <div class="span4"  style="min-height: 0;">
                    <p>The search box is limited to a complete Email address which it will
                    match (case is important) if that user exists.  Hit enter to search.</p>  
                </div>
            </div>
            <div class="row">
               <div class="span12">
                    <table cellpadding="0" cellspacing="0" border="0" class="display" id="userList">
                    <thead>
                        <tr>
                            <th>Email Address</th>
                            <th>Registration Date</th>
                            <th>Roles</th>
                            <th>Suspended</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Email Address</th>
                            <th>Registration Date</th>
                            <th>Roles</th>
                            <th>Suspended</th>
                        </tr>
                    </tfoot>
                    </table>
               </div>
            </div>
        </section>
    </div>

    <footer>
        <p>&copy; Cilogi Limited 2011</p>
    </footer>

</div>


<#include "inc/_foot.ftl">

<script src="js/lib/jquery.dataTables.min.js"></script>

<script>
    $(document).ready(function() {
        var oTable = $("#userList").dataTable({
            iDisplayLength: 20,
            //bFilter: false,
            bSort: false,
            bLengthChange: false,
            sPaginationType: "full_numbers",
            bProcessing: true,
            bServerSide: true,
            sAjaxSource: shiro.userBaseUrl + "/list",
            fnServerData: function ( sSource, aoData, fnCallback ) {
                $.ajax( {
                    "dataType": 'json',
                    "type": "POST",
                    "url": sSource,
                    "data": aoData,
                    "success": fnCallback
                } );
            }
        });

        // This change is done so that the search only occurs on enter (13).
        // First, we can't afford a search on each character over the wire, and
        // second at the moment the only search you can do is for a complete email address.
        // Once the full text search capability comes in we'll be able to do more.
        $('#userList_filter input').unbind();
        $('#userList_filter input').bind('keyup', function(e) {
           if(e.keyCode == 13) {
              oTable.fnFilter(this.value);
           }
        });

        // When a checkbox is changed both suspend or unsuspend the relevant
        // user and invalidate the cache so we can see the change if we come back to this
        // page later.
        $("#userList input[type='checkbox']").live("click", function() {
            var isChecked = $(this).is(":checked");
            var name = $(this).attr("name");
            $.ajax(shiro.userBaseUrl+"/suspend", {
                type: "POST",
                dataType: "json",
                data: {
                    username: name,
                    suspend: isChecked
                },
                success: function(data, status) {
                    alert(data.message);
                },
                error: function(xhr, message) {
                    alert("suspend failed: " + message);
                }
            });

            $.ajax(shiro.userBaseUrl+"/list", {
                type: "PUT",
                dataType: "json",
                data: {
                    invalidateCache: true
                }
            });

        });
    });
</script>

</body>
</html>