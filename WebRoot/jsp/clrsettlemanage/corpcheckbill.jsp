<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>数据采集</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		$(function(){
			//文件类型
			$("#fileType").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'01',codeName:"充值"},{codeValue:'03',codeName:"消费"}]
			});
			//是否有明细
			$("#existDetail").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"有"},{codeValue:'1',codeName:"无"}]
			});
			//结算状态
			$("#jsState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"是"},{codeValue:'1',codeName:"否"}]
			});
			//对账状态
			$("#procState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"对账平"},{codeValue:'1',codeName:"平账中"},{codeValue:'2',codeName:"对账不平明细未上传"},{codeValue:'3',codeName:"对账不平明细已上传"}]
			});
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"clrDeal/clrDealAction!findAllCheckBill.action",
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				fit:true,
				singleSelect:true,
				pageSize:20,
				frozenColumns:[[
					{field:'ID',checkbox:true},
					{field:'CO_ORG_ID',title:'合作机构编号',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'CO_ORG_NAME',title:'合作机构名称',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'CHECK_DATE',title:'对账日期',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'PROC_STATE',title:'对账状态',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'EXIST_DETAIL',title:'是否有记录',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'DZPZLX',title:'平账类型',sortable:true,width:parseInt($(this).width()*0.06)},
					{field:'JS_STATE',title:'是否生成结算单',sortable:true,width:parseInt($(this).width()*0.1)},
				]],
				columns:[[ 
					{field:'TOTAL_ZC_SUM',title:'上传正常笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'TOTAL_ZC_AMT',title:'上传正常金额',align:'center',sortable:true,width:parseInt($(this).width()*0.08),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'TOTAL_TH_SUM',title:'上传退货笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'TOTAL_TH_AMT',title:'上传退货笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'TOTAL_CX_SUM',title:'上传撤销笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'TOTAL_CX_AMT',title:'上传撤销笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'TOTAL_ZCFROMADD_SUM',title:'合作机构多出正常笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOTAL_ZCFROMADD_AMT',title:'合作机构多出正常金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'TOTAL_THFROMADD_SUM',title:'合作机构多出退货笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOTAL_THFROMADD_AMT',title:'合作机构多出退货金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'TOTAL_CXFROMADD_SUM',title:'合作机构多出撤销笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOTAL_CXFROMADD_AMT',title:'合作机构多出撤销金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'TOTAL_ZCTOADD_NUM',title:'运营机构多出正常笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOTAL_ZCTOADD_AMT',title:'运营机构多出正常金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'TOTAL_THTOADD_NUM',title:'运营机构多出退货笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOTAL_THTOADD_AMT',title:'运营机构多出退货金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'TOTAL_CXTOADD_NUM',title:'运营机构多出撤销笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOTAL_CXTOADD_AMT',title:'运营机构多出撤销金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'SJ_TOTAL_ZC_SUM',title:'平账后正常记录数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'SJ_TOTAL_ZC_AMT',title:'平账后正常金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'SJ_TOTAL_CX_SUM',title:'平账后退货记录数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'SJ_TOTAL_CX_AMT',title:'平账后退货金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:'SJ_TOTAL_TH_SUM',title:'平账后撤销记录数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'SJ_TOTAL_TH_AMT',title:'平账后撤销金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}}
				]],toolbar:'#tb',
				onLoadSuccess:function(data){
					  $("#dg").datagrid("resize");
	            	  $("input[type=checkbox]").each(function(){
	        				this.checked = false;
	        		  });
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	            }
			});
		});
		function autoCom(){
			if($("#coOrgId").val() == ""){
				$("#coOrgName").val("");
			}
			$("#coOrgId").autocomplete({
				position: {my:"left top",at:"left bottom",of:"#coOrgId"},
			    source: function(request,response){
				    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#coOrgId").val(),"queryType":"1","initCorpType":"1"},function(data){
				    	response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
				    },'json');
			    },
			    select: function(event,ui){
			      	$('#coOrgId').val(ui.item.label);
			        $('#coOrgName').val(ui.item.value);
			        return false;
			    },
		      	focus:function(event,ui){
			        return false;
		      	}
		    }); 
		}
		function autoComByName(){
			if($("#coOrgName").val() == ""){
				$("#coOrgId").val("");
			}
			$("#coOrgName").autocomplete({
			    source:function(request,response){
			        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#coOrgName").val(),"queryType":"0","initCorpType":"1"},function(data){
			            response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
			        },'json');
			    },
			    select: function(event,ui){
			    	$('#coOrgId').val(ui.item.value);
			        $('#coOrgName').val(ui.item.label);
			        return false;
			    },
			    focus: function(event,ui){
			        return false;
			    }
		    }); 
		}
		$(document).keydown(function (event){ 
			if(event.keyCode == 112){
				basePersonalinfoquery();
				event.preventDefault(); 
			}else if(event.keyCode == 115){
				addOrEditBasePersonal("1");
				event.preventDefault(); 
			}else{
				return true;
			}
		});
		
		//人员基本信息查询
		function querysignInfo(){
			$dg.datagrid("load",{
				queryType:"0",
				"sign.coOrgId":$("#coOrgId").val(),
				"checkStartDate":$("#checkStartDate").val(),
				"checkEndDate":$("#checkEndDate").val(),
				"sign.fileType":$("#fileType").combobox("getValue"),
				"sign.jsState":$("#jsState").combobox("getValue"),
				"sign.procState":$("#procState").combobox("getValue")
			});
		}
		//预览对账明细信息
		function viewchecklist(){
			var row = $dg.datagrid('getSelected');
			if(row){
				$.modalDialog({
					title:'对账明细数据',
					iconCls:'icon-termManage',
					fit:true,
					border:false,
					maximized:true,
					shadow:false,
					closable:false,
					maximizable:false,
					href:"jsp/clrsettlemanage/corpcheckbilLlist.jsp" ,
					onLoad:function(){
						if(row){
							viewcheckbillList(row.ID);
						}
					},
					tools:[
							{
								iconCls:'icon_cancel_01',
								handler:function(){
									$.modalDialog.handler.dialog('destroy');
								    $.modalDialog.handler = undefined;
							   }
							}
					]
				});
			}else{
				$.messager.alert("系统消息","请选择一条记录信息进行预览！","error");
			}
		}
		
	</script>
</head>
<body class="easyui-layout" data-options="fit:true, border:false">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>合作机构对账信息进行查看，对账操作！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width:8%">合作机构编号：</td>
					<td class="tableright" style="width:17%"><input type="text" name="sign.coOrgId" id="coOrgId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
					<td class="tableleft" style="width:8%">合作机构名称：</td>
					<td class="tableright" style="width:17%"><input type="text" name="coOrgName" id="coOrgName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					<td class="tableleft" style="width:8%">对账起始日期：</td>
					<td class="tableright" style="width:17%"><input type="text" name="checkStartDate" id="checkStartDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyyMMdd',qsEnabled:false,maxDate:'#F{$dp.$D(\'checkEndDate\')}'})"/></td>
					<td class="tableleft" style="width:8%">对账结束日期：</td>
					<td class="tableright" style="width:17%"><input type="text" name="checkEndDate" id="checkEndDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyyMMdd',qsEnabled:false,maxDate:'%y-%M-%d',minDate:'#F{$dp.$D(\'checkStartDate\')}'})"/></td>
					
				</tr>
				<tr>
					<td class="tableleft">对账类型：</td>
					<td class="tableright"><input type="text" name="sign.fileType" id="fileType" class="easyui-combobox" /></td>
					<td class="tableleft">对账状态：</td>
					<td class="tableright"><input type="text" name="sign.procState" id="procState" class="easyui-combobox" /></td>
					<td class="tableleft">是否生成结算单：</td>
					<td class="tableright"><input type="text" name="sign.jsState" id="jsState"  class="easyui-combobox"/></td>
					<td class="tableright" colspan="2">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="querysignInfo();">查询</a>
						<shiro:hasPermission name="coCheckViewList">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" plain="false" onclick="viewchecklist();">预览</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="对账信息列表"></table>
  	</div>
</body>
</html>
