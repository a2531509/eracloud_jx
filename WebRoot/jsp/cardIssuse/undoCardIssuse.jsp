<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function() {
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE"});
		createSysBranch({id:"brchId"},{id:"userId"});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			//minLength:"1"
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:"1"
		},"certNo");
		$grid = createDataGrid({
			id:"dg",
			url:"cardIssuse/cardIssuseAction!queryUndoCardIssue.action",
			pagination:true,
			border:false,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
				{field:'V_V',checkbox:true},
			    {field:'APPLY_ID',title:'申领编号',sortable:true},
				{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.15)},
				{field:'NAME',title:'客户姓名',sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:'APPLYSTATE',title:'申领状态',sortable:true,width:parseInt($(this).width() * 0.08),formatter:function(value,row,index){
					if(row["APPLY_STATE"] == "<%=com.erp.util.Constants.APPLY_STATE_YFF %>"){
						return "<span style=\"color:red;\">" + value + "</span>";
					}else{
						return value;
					}
				}},
				{field:'BIZ_DATE',title:'发放时间',sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:'CARDTYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:'BRCH_ID',title:'发放网点编号',sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:'USER_ID',title:'发放柜员编号',sortable:true,width:parseInt($(this).width() * 0.08)}
			]]
		});
	});
	
	function query(){
		var params = getformdata("searchConts");
		if(params["isNotBlankNum"] <= 0){
			$.messager.alert('系统消息','请至少输入一个查询条件进行查询！','warning');
			return;
		}
		params["queryType"] = "0";
		params["person.name"] = $("#name").val();
		$grid.datagrid("load",params);
	}
	
	function tosaveinfo(){
		 var rows = $grid.datagrid("getChecked");
		 if(rows.length == 1){
			 var dealNos = "";
			 for(var d = 0;d < rows.length;d++){
				 if(rows[d]["APPLY_STATE"] != "<%=com.erp.util.Constants.APPLY_STATE_YFF %>"){
					 $.messager.alert("系统消息","勾选的申领编号为" + rows[d]["APPLY_ID"] + "的发放记录对应的申领记录不是【已发放】状态，不能进行撤销！","error");
					 return;
				 }
				 dealNos = dealNos + rows[d].DEAL_NO + ",";
			 }
			 dealNos = dealNos.substring(0,dealNos.length - 1);
			 if(dealNull(dealNos).length <= 0){
				 $.messager.alert("系统消息","请勾选需要撤销的发放记录信息！","info");
				 return;
			 }
			 $.messager.confirm("系统消息","您确定要撤销勾选的发放记录吗？",function(r){
	     		if(r){
	     			$.messager.progress({text:"数据处理中，请稍后...."});
	  				$.post("cardIssuse/cardIssuseAction!saveUndoCardIssuse.action",{"taskIds":dealNos},function(data,status){
	  					$.messager.progress('close');
				     	if(data.status == "0"){
				     		$.messager.alert("系统消息","发放撤销保存成功！","info",function(){
					     		$grid.datagrid("reload");
				     			showReport("发放撤销",data.dealNo);
				     		});
				     	}else{
				     		$.messager.alert("系统消息",data.errMsg,"error");
				     	}
					},"json");
	     		}
	     	});
		 }else{
			 $.messager.alert("系统消息","请勾选一条发放记录进行撤销","error");
			 return;
		 }
	 }
</script>
<n:initpage title="个人发放记录进行撤销操作！">
	<n:center>
		<div id="tb" >
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
	                	<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="person.certNo"  class="textinput" id="certNo" type="text" maxlength="18"/></td>
						<td class="tableleft">客户姓名：</td>
						<td class="tableright"><input name="person.name"  class="textinput" id="name" type="text" maxlength="30"/></td>
						<td class="tableleft">发放日期始：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">发放日期始：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft" >发放网点：</td>
						<td class="tableright"><input id="brchId" name="brchId" type="text" class="textinput"/></td>
						<td class="tableleft" >发放柜员：</td>
						<td class="tableright"><input id="userId" name="userId" type="text" class="textinput"/></td>
						<td class="tableleft" >申领编号：</td>
						<td class="tableright" ><input id="applyId" name="applyId" type="text" class="textinput" maxlength="15"/></td>
						<td colspan="2" style="text-align:center;">
					    	<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="undoCardIssuse">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back"  plain="false" onclick="tosaveinfo();">确定撤销</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="个人发放记录信息"></table>
	 </n:center>
</n:initpage>