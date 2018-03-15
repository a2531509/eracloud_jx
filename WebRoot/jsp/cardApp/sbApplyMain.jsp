<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				toQuery();
			}
		});
		createSysBranch({
			id:"recvBrchId"
		});
		$.autoComplete({
			id:"corpId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:1
		},"corpName");
		$.autoComplete({
			id:"corpName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:1
		},"corpId");
		$grid = createDataGrid({
			id:"dg",
			url:"cardApplysbAction/cardApplysbAction!toQuerySbApplyInfo.action",
			fit:true,
			border:false,
			pageList:[20,50,100,500,1000,2000],
			singleSelect:false,
			ctrlSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
		      	{field:"EMP_ID1",sortable:true,checkbox:true},
		    	{field:"EMP_ID",title:"单位编号",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"EMP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"RECV_BRCH_ID",title:"领卡网点编号",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"RECV_BRCH_NAME",title:"领卡网点名称",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"COMPANYID",title:"社保系统单位编号",sortable:false,width:parseInt($(this).width()*0.1)},
		    	{field:"APPLY_NUM",title:"申报人员数量",sortable:true,width:parseInt($(this).width()*0.1)}
		    ]]
		});
	});
	function toQuery(){
		var params = getformdata("searchConts");
		params["corpName"] = dealNull($("#corpName").val());
		params["queryType"] = "0";
		$grid.datagrid("load",params);
	}
	function toView(){
		var rows = $grid.datagrid("getChecked");
		if(!rows || rows.length != 1){
			$.messager.alert("系统消息","请勾选一条记录信息进行查看！","error");
			return;
		}
		$.modalDialog({
			title:"社保申领信息预览",
			iconCls:"icon-viewInfo",
			fit:true,
			maximized:true,
			shadow:false,
			closable:false,
			maximizable:false,
			href:"jsp/cardApp/sbApplyView.jsp?selectedId=" + rows[0].EMP_ID1,
			tools:[{
				iconCls:"icon_cancel_01",
				handler:function(){
					$.modalDialog.handler.dialog("destroy");
				    $.modalDialog.handler = undefined;
			    }
			}]
		});
	}
	function toSbApply(){
		var rows = $grid.datagrid("getChecked");
		if(rows != null && rows.length > 0){
			var selectId ="";
			for(var i=0;i<rows.length;i++){
				if(i!=rows.length-1){
					selectId = selectId+rows[i].EMP_ID1 + ",";
				}else{
					selectId = selectId+rows[i].EMP_ID1;
				}
			}
			$.messager.confirm("系统消息","您确定要进行社保数据的申领？",function(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("cardApplysbAction/cardApplysbAction!saveSbApplyInfo.action?selectedId=" + selectId,function(rsp,status){
					$.messager.progress('close');
					if(rsp.status){
						$.messager.alert("系统消息","社保申领成功！","info");
					}else{
						$.messager.alert("系统消息","社保申领出错："+rsp.message,"error");
					}
				},'json');
			});
		}else{
			$.messager.alert("系统消息","请勾选记录信息进行申领！","error");
			return;
		}
	}
</script>
<n:initpage title="社保申领数据处理：<span style='color:red;'>注意：</span>只申领社保同步状态正常的人员信息！">
  	<n:center>
		<div id="tb">
			<form id="searchConts">
		        <table class="tablegrid">
					<tr id="dwapply" >
						<td class="tableleft" style="width:8%">单位编号：</td>
						<td class="tableright" style="width:17%"><input name="corpId"  class="textinput" id="corpId" type="text" maxlength="20"/></td>
						<td class="tableleft" style="width:8%">单位名称：</td>
						<td class="tableright" style="width:17%"><input name="corpName"  class="textinput" id="corpName" type="text" maxlength="50"/></td>
						<td class="tableleft" style="width:8%">领卡网点：</td>
						<td class="tableright" style="width:17%"><input name="recvBrchId"  class="textinput" id="recvBrchId" type="text"/></td>
						<td class="tableright" style="width:25%" colspan="2">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'"  onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-viewInfo'"  onclick="toView()">预览</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-save'" onclick="toSbApply()">申领</a>
						</td>
					</tr>
			    </table>
		    </form>
		</div>
  		<table id="dg" title="社保申领信息"></table>
	</n:center>
</n:initpage>