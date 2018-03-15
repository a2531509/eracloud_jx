<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>现金尾箱</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		
		var sAmt = 0;
		var fAmt = 0;
		var count = 0;
		
		$(function() {
			createSys_Org({id:"orgId"},{id:"branchId"},{id:"operatorId"});
			createSysCode({
				id:"inOutFlag2",
				codeType:"IN_OUT_FLAG"
			})
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"cashManage/cashManageAction!queryCashBoxRec.action",
				pagination:true,
				fit:true,
				toolbar:$("#tb"),
				pageSize:20,
				striped:true,
				border:false,
				rownumbers:true,
				showFooter:true,
				fitColumns:true,
				singleSelect:false,
				frozenColumns:[ [
				    {field:"", checkbox:true},
					{field:"CASH_SER_NO", title:"流水号", sortable:true},
					{field:"BRCH_ID", title:"网点编号", sortable:true, width : parseInt($(this).width() * 0.06)},
					{field:"FULL_NAME", title:"网点名称", sortable:true, width : parseInt($(this).width() * 0.1)},
					{field:"USER_ID", title:"柜员编号", sortable:true, width : parseInt($(this).width() * 0.05)},
					{field:"NAME", title:"柜员名称", sortable:true, width : parseInt($(this).width() * 0.05)},
					{field:"COIN_KIND", title:"币种", sortable:true, width : parseInt($(this).width() * 0.04)},
					{field:"IN_OUT_FLAG", title:"收付标志", sortable:true, width : parseInt($(this).width() * 0.08), formatter:function(v, r){
						if(r.isFooter){
							return v;
						} else if(v == 1){
							return "收";
						} else {
							return "付";
						}
					}},
					{field:"AMT", title:"金额", sortable:true, width : parseInt($(this).width() * 0.08), formatter:function(v, r){
						if(r.isFooter){
							return v;
						}
						return $.foramtMoney(Number(v).div100());
					}},
					{field:"CS_BAL", title:"现金结存", sortable:true, width : parseInt($(this).width() * 0.06), formatter:function(v, r){
						if(r.isFooter){
							return v;
						}
						return $.foramtMoney(Number(v).div100());
					}}
				]],
				columns:[[
					{field:"DEAL_CODE_NAME", title:"交易名称", sortable:true},
					{field:"DEAL_NO", title:"业务流水", sortable:true},
					{field:"IN_OUT_DATE", title:"发生日期", sortable:true},
					{field:"CLR_DATE", title:"清分日期", sortable:true},
					{field:"SUMMARY", title:"备注", sortable:true}
				]],
				onLoadSuccess:function(data) {
					if (data.status != "0") {
						$.messager.alert('系统消息', data.errMsg, 'error');
					}
					sAmt = 0;
					fAmt = 0;
					count = 0;
					updateFooter();
				},
				queryParams:{
					
				},
				onBeforeLoad:function(param){
					if(!param["userId"]||param["userId"]==""){
						return false;
					}
				},
				onSelect:function(index, row){
					if(row.IN_OUT_FLAG){
						sAmt += Number(row.AMT);
					} else {
						fAmt += Number(row.AMT);
					}
					count++;
					updateFooter();
				},
				onUnselect:function(index, row){
					if(row.IN_OUT_FLAG){
						sAmt -= Number(row.AMT);
					} else {
						fAmt -= Number(row.AMT);
					}
					count--;
					updateFooter();
				},
				onSelectAll:function(rows){
					sAmt = 0;
					fAmt = 0;
					num = 0;
					for(var i in rows){
						if(rows[i].IN_OUT_FLAG){
							sAmt += Number(rows[i].AMT);
						} else {
							fAmt += Number(rows[i].AMT);
						}
						count++;
					}
					updateFooter();
				},
				onUnselectAll:function(rows){
					sAmt = 0;
					fAmt = 0;
					count = 0;
					updateFooter();
				}
			});
		});
		
		function updateFooter(){
			$grid.datagrid("reloadFooter",[{
				isFooter:true,
				BRCH_ID:"统计：",
				FULL_NAME:"共 " + count + " 条记录",
				IN_OUT_FLAG: "收：" + $.foramtMoney(Number(sAmt).div100()),
	        	AMT :"付：" + $.foramtMoney(Number(fAmt).div100())
			}]);
		}
		
		function query2(){
			var userId = $("#operatorId").combobox('getValue');
			if(userId == ""){
				$.messager.alert("系统消息", "请输入柜员", "warning");
				return;
			}
			
			$("#dg").datagrid("load", {
				"inOutFlag":$("#inOutFlag2").combobox("getValue"),
				"beginTime":$("#startDate2").val(),
				"endTime":$("#endDate2").val(),
				userId:userId
			});
		}
		
		function exportExcel(){
			var userId = $("#operatorId").combobox('getValue');
			if(userId == ""){
				$.messager.alert("系统消息", "请输入柜员", "warning");
				return;
			}
			
			var selections = $grid.datagrid("getSelections");
			var dealNos = "";
			if(selections && selections.length > 0){
				for(var i in selections){
					dealNos += selections[i].CASH_SER_NO + ",";
				}
			}
			
			var url = 'cashManage/cashManageAction!exportCashBoxRec.action?queryType=0&rows=20000&serNos=' + dealNos.substring(0, dealNos.length - 1);
			url += "&inOutFlag=" + $("#inOutFlag2").combobox("getValue") + "&beginTime=" + $("#startDate2").val() + "&endTime=" + $("#endDate2").val() + "&userId=" + userId;
			$('#downloadcsv').attr('src',url);
		}
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>柜员尾箱流水信息</strong></span>进行查询!</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td class="tableleft">所属机构：</td>
					<td class="tableright"><input id="orgId" type="text" class="textinput" name="orgId"  style="width:174px;"/></td>
					<td class="tableleft">所属网点：</td>
					<td class="tableright"><input id="branchId" type="text" class="textinput" name="branchId"  style="width:174px;"/></td>
					<td class="tableleft">柜员：</td>
					<td class="tableright"><input id="operatorId" type="text" class="textinput" name="operatorId"  style="width:174px;"/></td>
				</tr>
				<tr>
					<td class="tableleft">收付标志：</td>
					<td class="tableright"><input id="inOutFlag2" class="textinput" /></td>
					<td class="tableleft">启始时间：</td>
					<td class="tableright"><input id="startDate2" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					<td class="tableleft">结束时间：</td>
					<td class="tableright">
						<input id="endDate2" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="query2()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel" onclick="exportExcel()">导出</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="柜员尾箱流水信息"></table>
	</div>
	<iframe id="downloadcsv" style="display:none"></iframe>
</body>
</html>