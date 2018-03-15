<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
    var $gridview;
    $(function(){
        $gridview = createDataGrid({
            id:"dgview",
            url:"cardService/cardServiceAction!queryZXCDetailed.action",
            border:false,
            fit:true,
            singleSelect:true,
            queryParams:{queryType:"1"},
            scrollbarSize:0,
            pageSize:100,
            toolbar:"#tbview",
            fitColumns:false,
            pageList:[50,100,200,300,500],
            frozenColumns:[[
                {field:"CUSTOMER_NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.09)},
                {field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"BIZ_TIME",title:"开通时间",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"RSV_ONE",title:"押金类型",sortable:true,width:parseInt($(this).width() * 0.1),formatter:function(value,row,index){
                	 if(row.RSV_ONE != "开通"){
                         return "<span style='color:red;'>" + value + "</span>";
                     }else{
                         return "<span style='color:green'>" + value + "</span>";
                     }
                 }},
                {field:"RTN_FGFT",title:"押金金额",sortable:true,width:parseInt($(this).width() * 0.1)},
                {field:"ACPT_ID",title:"网点名称",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"USER_ID",title:"操作柜员",sortable:true,width:parseInt($(this).width() * 0.08)}
            ]],
        });
    });
    function toQueryTaskList(){
        var params = getformdata("viewSearchConts");
        params["queryType"] = "0";
        $gridview.datagrid("load",params);
    }
</script>
<n:initpage title="自行车开通终止数据明细进行查询操作!">
    <n:center>
        <div id="tbview">
            <form id="viewSearchConts">
                <table class="tablegrid">
                    <tr>
                        <td class="tableleft">证件号码：</td>
                        <td class="tableright"><input id="certNo" name="bp.certNo" type="text" class="textinput" maxlength="18"/></td>
                        <td class="tableleft">卡号：</td>
                        <td class="tableright"><input id="cardNo" name="bp.name" type="text" class="textinput" maxlength="15"/></td>
                        <td class="tableleft">开始日期：</td>
                        <td class="tableright"><input id="startDate" name="startDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableleft">结束日期：</td>
                        <td class="tableright"><input id="endTime" name="endTime" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableright">
                            <a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryTaskList()">查询</a>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="dgview" title="自行车开通终止明细"></table>
    </n:center>
</n:initpage>