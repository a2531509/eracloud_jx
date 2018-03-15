<%--
  Created by IntelliJ IDEA.
  User: yangn
  Date: 2016-09-12
  Time: 10:54:35
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $gridview;
	$(function(){
		 createRecvBranch(
            {id:"recvBrchId"}
        );
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			to:10
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:1,
			to:10
		},"certNo");
		$gridview = createDataGrid({
			id:"dgview",
			url:"cardapply/cardApplyAction!toViewJrsbkImportData.action?rec.dealNo=${param.dealNo}",
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
				{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"REGION_ID",title:"统筹区编码",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"REGION_NAME",title:"统筹区名称",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"BANK_ID",title:"银行编码",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"BANK_NAME",title:"银行名称",sortable:true,width:parseInt($(this).width() * 0.1)},
				{field:"RECV_BRCH_ID",title:"领卡网点编码",sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:"FULL_NAME",title:"领卡网点名称",sortable:true}        
		    ]],
	    	columns:[[
				{field:"TASK_ID",title:"任务编号",sortable:true,width:parseInt($(this).width() * 0.11)},
				{field:"TASK_NAME",title:"任务名称",sortable:true},
				{field:"APPLYTYPE",title:"申领类型",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"STATETYPE",title:"状态",sortable:true,width:parseInt($(this).width() * 0.05),formatter:function(value,row,index){
					if(dealNull(row.DEAL_STATE) == "1"){
						return "<span style='color:red'>" + value + "</span>";
					}else{
						return value;
					}
				}},
				{field:"DEAL_MSG",title:"备注",width:parseInt($(this).width() * 0.12)}
			]]
		});
	});
	function toQueryTaskList(){
		var params = getformdata("viewSearchConts");
		params["queryType"] = "0";
		params["bp.name"] = $("#name").val();
		params["bp.certNo"] = $("#certNo").val();
		params["apply.recvBrchId"] = $("#recvBrchId").combobox("getValue");
		params["apply.taskId"] = $("#taskId").val();
		$gridview.datagrid("load",params);
	}
</script>
<n:initpage title="金融市民卡申领导入数据明细进行查询操作!">
	<n:center>
		<div id="tbview">
			<form id="viewSearchConts">
				<table class="tablegrid">
					<tr>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input id="certNo" name="bp.certNo" type="text" class="textinput" maxlength="18"/></td>
						<td class="tableleft">姓名：</td>
						<td class="tableright"><input id="name" name="bp.name" type="text" class="textinput" maxlength="15"/></td>
						<td class="tableleft">领卡网点：</td>
						<td class="tableright"><input id="recvBrchId" name="apply.recvBrchId" type="text" class="textinput" maxlength="18"/></td>
						<td class="tableleft">任务名称：</td>
						<td class="tableright"><input id="taskId" name="apply.taskId" type="text" class="textinput" maxlength="30"/></td>
						<td class="tableright">
							<a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryTaskList()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
	  	<table id="dgview" title="金融市民卡申领导入数据明细"></table>
	</n:center>
</n:initpage>