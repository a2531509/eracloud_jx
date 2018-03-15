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
    <title>系统业务凭证查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style>
		.combobox-item{
			cursor:pointer;
		}
		.panel-with-icon:{padding-left:0px;marign-left:0px;}
		.panel-title:{width:13px;padding-left:0px;}
	</style>
	<script type="text/javascript"> 
	//$.fn.datagrid.defaults.loadMsg = '正在处理，请稍待。。。';
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			createSysBranch(
				{id:"branchId"},
				{id:"userId"}
			);
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "statistical/statisticalAnalysisAction!voucherQuery.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				border:true,
				striped:true,
				pageSize:20,
				singleSelect:true,
				autoRowHeight:true,
				showFooter: true,
				scrollbarSize:0,
				fitColumns:true,
				//scrollbarSize:0,
				columns :[[
							{field:'V_V',title:'',sortable:true,checkbox:true},
							{field:'DEAL_NO',title:'流水号',sortable:true,width:parseInt($(this).width() * 0.06),fixed:true},
							{field:'RP_TITILE',title:'凭证标题',sortable:true},
							{field:'FORMAT',title:'格式',sortable:true,width:parseInt($(this).width() * 0.04)},
							{field:'BRCH_ID',title:'网点编号',sortable:true,width:parseInt($(this).width() * 0.08)},
							{field:'FULL_NAME',title:'网点名称',sortable:true,width:parseInt($(this).width() * 0.15)},
							{field:'USER_ID',title:'柜员编号',sortable:true,width:parseInt($(this).width() * 0.1)},
							{field:'NAME',title:'柜员名称',sortable:true,width:parseInt($(this).width() * 0.08)},
							{field:'DEALTIME',title:'操作时间',sortable:true,width:parseInt($(this).width() * 0.12),fixed:true}
						]],
				  toolbar:'#tb',
	              onLoadSuccess:function(data){
	            	  $("input[type=checkbox]").each(function(){
	        				this.checked = false;
	        		  });
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	              }
			});
		});
		function query(){
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				branchId:$("#branchId").combobox('getValue'), 
				userId:$("#userId").combobox('getValue'),
				beginTime:$('#beginTime').val(),
			    endTime:$('#endTime').val(),
			    dealNo:$('#dealNo').val(),
			    reportTitle:$('#reportTitle').val()
			});
		}
		function view(){
			var selectRow = $dg.datagrid('getSelected');
			if(selectRow){
				//odefaultwindow(selectRow.RP_TITILE,'/commAction!execute.action?actionNo=' + selectRow.ACTION_NO);
				showReport(selectRow.RP_TITILE,selectRow.DEAL_NO);
			}else{
				parent.$.messager.show({
					title :'系统消息',
					msg : '预览凭证请至少选择一行！',
					timeout : 1000 * 2
   				});
			}
		}
	function viewQM(){
			var selectRow = $dg.datagrid('getSelected');
			if(selectRow){
				odefaultwindow(selectRow.RP_TITILE,'/commAction!viewQm.action?actionNo=' + selectRow.DEAL_NO);
				//showReport(selectRow.RP_TITILE,selectRow.DEAL_NO);
			}else{
				parent.$.messager.show({
					title :'系统消息',
					msg : '预览凭证请至少选择一行！',
					timeout : 1000 * 2
   				});
			}
		}
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>系统业务凭证</strong></span>进行查询!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft">流水号：</td>
						<td class="tableright"><input id="dealNo" type="text"  class="textinput easyui-validatebox" name="dealNo"/></td>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput" name="branchId"/></td>
						<td class="tableleft">柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput" name="userId"/>
						 <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-viewInfo'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="viewQM();">预览签名凭证</a>
						</td>
					</tr>
					<tr>
						<td class="tableleft">标题：</td>
						<td class="tableright"><input id="reportTitle" type="text" class="textinput easyui-validatebox" name="reportTitle"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright">
							<input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
							<shiro:hasPermission name="voucherQuery">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-viewInfo'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">预览</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="业务凭证信息"></table>
	  </div>
</body>
</html>