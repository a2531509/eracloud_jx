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
    <title>合作机构入网审核</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		$(function(){
			$("#coState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:"0",codeName:"正常"},{codeValue:"1",codeName:"注销"},{codeValue:"2",codeName:"待审核"},{codeValue:"9",codeName:"审核不通过"}]
			});
			$("#coOrgType").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'01',codeName:"合作机构"},{codeValue:'02',codeName:"商户合作机构"}]
			});
			$("#checkType").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'1',codeName:"运营机构数据为主"},{codeValue:'2',codeName:"合作机构数据为主"},{codeValue:'3',codeName:"人工干预实际交易数据"}]
			});
			$("#indusCode").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:"1",codeName:"银行"},{codeValue:"2",codeName:"连锁加盟"}]
			});
			$("#stlType").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:"",codeName:"请选择"},{codeValue:"0",codeName:"自己结算"},{codeValue:"1",codeName:"上级结构结算"}]
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"cooperationAgencyManager/cooperationAgencyAction!toFindAllCooperAgencyMsg.action",
				pagination:true,
				rownumbers:true,
				border:true,
				striped:true,
				fit:true,
				//fitColumns:true,
				scrollbarSize:0,
				singleSelect:true,
				pageSize:20,
				frozenColumns:[[
					{field:'CUSTOMER_ID',checkbox:true,sortable:true},
					{field:'CO_ORG_ID',title:'合作机构编号',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'CO_ORG_NAME',title:'合作机构名称',sortable:true,width:parseInt($(this).width()*0.12)},
					{field:'CO_ABBR_NAME',title:'合作机构简称',sortable:true,width:parseInt($(this).width()*0.12)},
				]],
				columns:[[ 
					{field:'CO_ORG_TYPE',title:'合作机构类型',sortable:true,width:parseInt($(this).width()*0.08),formatter:function(value,row,index){
						if(value == "01"){
							return "合作机构";
						}else if(value == "02"){
							return "商户合作机构";
						}else{
							return "未知类型";
						}
					}},
					{field:'CHECK_TYPE',title:'对账数据主体',sortable:true,width:parseInt($(this).width()*0.12),formatter:function(value,row,index){
						if(value == "1"){
							return "运营机构数据为主体";
						}else if(value == "2"){
							return "合作机构数据为主体";
						}else if(value == "3"){
							return "人工干预实际交易数据";
						}else{
							return "未说明";
						}
					}},
					{field:'INDUS_CODE',title:'所属行业',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
						if(value == "1"){
							return "银行";
						}else if(value == "2"){
							return "连锁加盟";
						}else{
							return "未说明";
						}
					}},
					{field:'STL_TYPE',title:'结算方式',sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
						if(value == "0"){
							return "自己结算";
						}else if(value == "1"){
							return "上级结构结算";
						}else{
							return "未说明";
						}
					}},
					{field:'CO_STATE',title:'状态',sortable:true,width:parseInt($(this).width()*0.05),formatter:function(value,row,index){
						if(value == 1){return '注销';}else if(value == '0'){return '正常';}else if(value == 2){return '待审核';}else if(value==9){return '审核不通过'}
					}},
					{field:'ORG_ID',title:'运营机构编号',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'ORG_NAME',title:'运营机构名称',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOP_CO_ORG_ID',title:'上一级合作机构编号',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'TOP_ORG_NAME',title:'上一级合作机构名称',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'CONTACT',title:'联系人',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'CON_PHONE',title:'联系人电话',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'SIGN_DATE',title:'注册时间',sortable:true,width:parseInt($(this).width()*0.13)},
					{field:'SIGN_USER_ID',title:'注册人',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'NOTE',title:'备注',sortable:true,width:parseInt($(this).width()*0.15)}
				]],toolbar:'#tb',
				onLoadSuccess:function(data){
					  $("#dg").datagrid("resize");
	            	  $("input[type=checkbox]").each(function(){
	        				this.checked = false;
	        		  });
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	            },
	            onDblClickRow:function(index,rowdata){
	            	addOrEditBaseCoOrg('1');
	            }
			});			
		});
		//合作机构信息查询
		function basecoorginfoquery(){
			var c = getformdata("searchCont");
			c["queryType"] = "0";
			$dg.datagrid("load",c);
		}
		function addOrEditBaseCoOrg(type) {
			var row = $dg.datagrid('getSelected');
			if(type == '0' || (row && type == '1')){
				var titlestring = "",titleicon = "",customerId = "";
				if(type == "0"){
					titlestring = "合作机构信息新增";titleicon = "icon-add";
				}else if(type == '1'){
					titlestring = "合作机构信息编辑";titleicon = "icon-edit";customerId = row.CUSTOMER_ID;
				}else{
					$.messager.alert("系统消息","操作类型传入错误！","error");return;
				}
				$.modalDialog({
					title:titlestring,
					iconCls:titleicon,
					fit:true,
					maximized:true,
					shadow:false,
					//inline:true,
					closable:false,
					maximizable:false,
					href:"cooperationAgencyManager/cooperationAgencyAction!toAddOrEditIndex.action?queryType=" + type + "&co.coOrgId=" + customerId ,
					buttons:[{text:'保存',iconCls:'icon-ok',handler:function(){saveBaseCoOrg();}},
					         {text:'取消',iconCls:'icon-cancel',handler:function(){
									$.modalDialog.handler.dialog('destroy');
								    $.modalDialog.handler = undefined;
							 	}
							 }
				   ]
				});
			}else{
				$.messager.alert("系统消息","请选择一条记录信息进行编辑！","error");
			}
		}
		function autoCom(){
			if($("#coOrgId").val() == ""){
				$("#coOrgName").val("");
			}
			$("#coOrgId").autocomplete({
				position: {my:"left top",at:"left bottom",of:"#coOrgId"},
			    source: function(request,response){
				    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#coOrgId").val(),"queryType":"1"},function(data){
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
			        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#coOrgName").val(),"queryType":"0"},function(data){
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
		function checkinfo(state){
			var row = $dg.datagrid('getSelected');
			var string = "";
			if(row){
				if(state == "0"){
					string = "审核通过";
				}else if(state == "1"){
					string = "注销";
				}else if(state == "3"){
					string = "启用";
				}else if(state == "9"){
					string = "审核不通过";
				}else{
					$.messager.alert("系统消息","传入操作类型错误！","error");
					return;
				}
				$.messager.confirm("系统消息","您确定要" + string +"【" + row.CO_ORG_NAME + "】该合作商户信息吗？",function(r){
					if(r){
						$.post('cooperationAgencyManager/cooperationAgencyAction!coOrgStateManager.action',{"co.customerId":row.CUSTOMER_ID,"queryType":state},function(data,status){
							if(status == 'success'){
								$.messager.alert("系统消息",data.msg,(data.status == 0 ? "info" : "error"),function(){
									if(data.status == "0"){
										$dg.datagrid("reload");
									}
								});
							}else{
								$.messager.alert("系统消息",string + "该合作商户信息发生错误：请重新进行操作！","error");
							}
						},'json');
					}
				});
			}else{
				$.messager.alert("系统消息","请选择一条记录进行操作","error");
			}
		}
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>合作机构入网登记信息进行审核管理！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		<div id="tb" style="padding:2px 0">
			<form id="searchCont">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft">合作机构号：</td>
						<td class="tableright"><input type="text" name="co.coOrgId" id="coOrgId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">合作机构名称：</td>
						<td class="tableright"><input type="text" name="co.coOrgName" id="coOrgName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<th class="tableleft">所属行业：</th><!-- （比如银行、连锁加盟商等） -->
						<td class="tableright"><input name="co.indusCode" id="indusCode" type="text" class="textinput"/></td>
						<th class="tableleft">对账数据主体：</th>
						<td class="tableright"><input id="checkType" name="co.checkType" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<th class="tableleft">结算方式：</th><!-- 自己单独结算还是上级结算，0是自己结算，1上级机构结算 -->
						<td class="tableright"><input name="co.stlType" id="stlType" type="text" class="textinput"/></td>
						<td class="tableleft">合作机构类型：</td>
						<td class="tableright"><input type="text" name="co.coOrgType" id="coOrgType" class="textinput"/></td>
						<td class="tableleft">状态：</td>
						<td class="tableright"><input type="text" name="co.coState" id="coState" class="textinput"/></td>
						<td style="padding:2px;" colspan="2">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="basecoorginfoquery();">查询</a>
							<shiro:hasPermission name="basecoorgmanageAdd">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-add" plain="false" onclick="addOrEditBaseCoOrg('0');">添加</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="basecoorgmanageEdit">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit" plain="false" onclick="addOrEditBaseCoOrg('1')">编辑</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="basecoorgmanageSh">
								<a href="javascript:void(0);" class="easyui-menubutton" iconCls="icon-checkInfo" data-options="menu:'#mm1'" plain="false" onclick="javascript:void(0)">审核管理</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="basecoorgmanageState">
								<a href="javascript:void(0);" class="easyui-menubutton" iconCls="icon-checkInfo" data-options="menu:'#mm2'" plain="false" onclick="javascript:void(0)">状态管理</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<div id="mm1" style="width:50px;display: none;">
			<div data-options="iconCls:'icon-ok'" onclick="checkinfo('0')">审核通过</div>
			<div class="menu-sep"></div>
			<div data-options="iconCls:'icon_cancel_01'" onclick="checkinfo('9')">审核不通过</div>
		</div>
		<div id="mm2" style="width:30px;display: none;">
			<div data-options="iconCls:'icon-account_enable'" onclick="checkinfo('3')">启用</div>
			<div class="menu-sep"></div>
			<div data-options="iconCls:'icon_cancel_01'" onclick="checkinfo('1')">注销</div>
		</div>
  		<table id="dg" title="合作机构信息"></table>
  	</div>
</body>
</html>