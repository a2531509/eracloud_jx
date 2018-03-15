<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
    var $gridview;
    $(function(){
    	$("#dgview").datagrid({
            id:"dgview",
            url:"cardService/cardServiceAction!queryZXCAggregatQuery.action",
            pagination:true,
            fitColumns:true,
            border:false,
            fit:true,
            singleSelect:true,
            queryParams:{queryType:"1"},
            scrollbarSize:0,
            pageSize:100,
            toolbar:"#tbview",
            fitColumns:false,
            rownumbers:true,
            pageList:[5,10],
            frozenColumns:[[
            	{field:"MON",title:"月份",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"OPEN_NUM",title:"开通总笔数",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"OPEN_SUM",title:"总押金",sortable:true,width:parseInt($(this).width() * 0.12),formatter:function(value,row,index){
                	if(value == "0"){
						return "0.00";
					}else{
						return $.foramtMoney(Number(value).div100());
					}
                }},
                {field:"CLOSE_NUM",title:"总终止笔数",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"CLOSE_SUM",title:"总退还押金",sortable:true,width:parseInt($(this).width() * 0.12),formatter:function(value,row,index){
                	if(value == "0"){
						return "0.00";
					}else{
						return $.foramtMoney(Number(value).div100());
					}
                }},
                {field:"BALANCE_NUM",title:"结余总笔数",sortable:true,width:parseInt($(this).width() * 0.12),formatter:function(value,row,index){
                	return row.OPEN_NUM - row.CLOSE_NUM;
                }},
                {field:"BALANCE_SUM",title:"结余总金额",sortable:true,width:parseInt($(this).width() * 0.12),formatter:function(value,row,index){
                	sum = row.OPEN_SUM - row.CLOSE_SUM;
                	return $.foramtMoney(Number(sum).div100());
                	
                }}
            ]],
            onLoadSuccess:function(data){
				if(data.status != "0"){
					jAlert(data.errMsg, "warning");
				}
			},
            
        });
    });
    

    
    function toQueryList(){
        var params = getformdata("viewSearchConts");
        params["queryType"] = "0";
        $gridview.datagrid("load",params);
    }
</script>
<n:initpage title="自行车汇总数据统计!">
    <n:center>
        <div id="tbview">
            <form id="viewSearchConts">
                <table class="tablegrid">
                    <tr>
                        <td class="tableright">
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="dgview" title="自行车汇总统计"></table>
    </n:center>
</n:initpage>