<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>批量申领</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">   
	<style type="text/css">
		.label_left{text-align:right;padding-right:2px;height:28px;font-weight:400;}
		.label_right{text-align:left;padding-left:2px;height:28px;}
		#tb table,#tb table td{border:1px dotted rgb(149, 184, 231);}
		#tb table{border-left:none;border-right:none;}
		body{font-family:'微软雅黑'}
	</style>  
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var  $personinfo;//人员列表
	$(function(){
		 //编辑的时候初始化下拉列表（城市、区域、街道和县）
		 $("#cityId").combobox({ 
		    url:"cityRegionTown/cityRegionTownAction!findAllCity.action",
		    editable:false,
		    cache: false,
		   	panelHeight: 'auto',
		    valueField:'cityId',   
		    textField:'cityName',
		    onLoadSuccess:function(){
		 		var cys = $(this).combobox('getData');
		 		if(typeof(cys) == 'object'){
		 			$(this).combobox('setValue',cys[0].cityId);
		 		}
		    }
	      }); 
		 $("#regionId").combobox({ 
		    url:"cityRegionTown/cityRegionTownAction!findRegionByRegionId.action",
		    editable:false,
		    cache: false,
		    panelHeight:'auto',
		    valueField:'regionId',   
		    textField:'regionName',
	    	onSelect:function(node){
	    		 $("#townId").combobox('reload','cityRegionTown/cityRegionTownAction!findAllTownByRegion.action?regionCode=' + node.regionId);
	    	},
	    	onLoadSuccess:function(){
		 		var cys = $("#regionId").combobox('getData');
		 		if(typeof(cys) == 'object'){
		 			$(this).combobox('setValue',cys[0].regionId);
		 		}
		    }
 		 }); 
		 $("#townId").combobox({ 
		    editable:false,
		    cache: false,
		    valueField:'townId',   
		    textField:'townName',
		    onLoadSuccess:function(){
		 		var cys = $(this).combobox('getData');
		 		if(typeof(cys) == 'object'){
		 			$(this).combobox('setValue',cys[0].townId);
		 		}
		    }
 		 });
		 $personinfo = $("#personinfo");
		 $personinfo.datagrid({
			url : "/cardapply/cardApplyAction!toGetAllBasePersonalByCondition.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			pageList:[50,100,500,1000,5000,10000],
			striped:true,
			loadMsg:'正在加载数据,请稍后...',
			//singleSelect:true,
			fitColumns:true,
			columns:[[
			      	{field:'NUM',sortable:true,checkbox:true},
			    	{field:'CUSTOMER_ID',title:'客户编号',sortable:true},
			    	{field:'NAME',title:'姓名',sortable:true},
			    	{field:'CERTTYPE',title:'证件类型',sortable:true},
			    	{field:'CERT_NO',title:'证件号码',sortable:true},
			    	{field:'BIRTHDAY',title:'出生年月',sortable:true},
			    	{field:'GENDER',title:'性别',sortable:true},
			    	{field:'NATION',title:'民族',sortable:true},
			    	{field:'CITYNAME',title:'所属城市',sortable:true},
			    	{field:'REGIONNAME',title:'所属区域',sortable:true},
			    	{field:'TOWNNAME',title:'村镇/社区',sortable:true},
			    	{field:'LETTER_ADDR',title:'通信地址',sortable:true},
			    	{field:'SURE_FLAG',title:'是否确认',sortable:true}
			    ]],
		 	toolbar:'#tb',
		 	onLoadSuccess:function(data){
		 		if(dealNull(data.errMsg).length > 0){
		 			$.messager.alert('系统消息',data.errMsg,'error');
		 		}
		 	}
		 });
		 //初始化表格
		 $personinfo.datagrid('reload',
			{
				queryType:'0',
				cardType:$('#cardType').val(),
				applyWay:$('#applyWay').val(),
				isSelected:$('#isSelected').val(),
				companyNo:$('#companyNo').val(),
				cityId:$('#cityId').val(),
				regionId:$('#regionId').val(),
				townId:$('#townId').val(),
				beginTime:$('#beginTime').val(),
				endTime:$('#endTime').val()
			}
		);
	});
	function query(){
		$personinfo.datagrid('reload',
			{
				queryType:'0',
				cardType:$('#cardType').val(),
				applyWay:$('#applyWay').val(),
				isSelected:$('#isSelected').val(),
				companyNo:$('#companyNo').val(),
				cityId:$('#cityId').val(),
				regionId:$('#regionId').val(),
				townId:$('#townId').val(),
				beginTime:$('#beginTime').val(),
				endTime:$('#endTime').val()
			}
		);
	}
	function addPersonList(){
		var datas =  $personinfo.datagrid('getData');
		if(datas && datas.rows.length > 0){
			window.parent.insertRows_(datas.rows);
		}
	}
</script>
</head>
<body>
  <div class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 			<div class="well well-small" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>
				在此您可以进行<span class="label-info"><strong>批量申领</strong>操作! <span style="color:red">注意：</span>排除/选中申领，排除即是在选择条件内排除所勾选的，其他人员全部进行申领；选中即是只申领勾选的人员；</span>
			</span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto">
	  	<div id="tb" style="padding:2px 0">
	  		<form id="selectedperson">
		  		<input type="hidden" name="queryType" value="${queryType}"/>
		  		<input type="hidden" name="cardType" value="${cardType}"/>
		  		<input type="hidden" name="applyWay" value="${applyWay}"/>
		  		<input type="hidden" name="isSelected" value="${isSelected}"/>
		  		<input type="hidden" name="companyNo" value="${companyNo}"/>
		  		<input type="hidden" name="cityId" value="${cityId}"/>
		  		<input type="hidden" name="regionId" value="${regionId}"/>
		  		<input type="hidden" name="townId" value="${townId}"/>
		  		<input type="hidden" name="beginTime" value="${beginTime}"/>
		  		<input type="hidden" name="endTime" value="${endTime}"/>
		  	</form>
			<table cellpadding="0" cellspacing="0" style="width:100%">
				<tr id="dwapply" style="display:none;">
					<td align="right" class="label_left">单位编号：</td>
					<td align="left" class="label_right"><input name="companyNo"  class="textinput" id="companyNo" type="text"/></td>
					<td align="right" class="label_left">单位名称：</td>
					<td align="left" class="label_right" colspan="1"><input name="companyName"  class="textinput" id="companyName" type="text"/></td>
					<td style="padding-left:2px">&nbsp;</td>
					<td style="padding-left:2px">&nbsp;</td>
				</tr>
				<tr id="sqapply">
				 	<td align="right" class="label_left">所属城市：</td>
					<td align="left" class="label_right"><input name="cityId"  class="easyui-combobox"  id="cityId"  type="text" style="width:174px;"/></td>
					<td align="right" class="label_left">所属区域：</td>
					<td align="left" class="label_right"><input name="regionId"  class="easyui-combobox" id="regionId"  type="text" style="width:174px;"/></td>
					<td align="right" class="label_left">所属街道/村镇/社区：</td>
					<td align="left" class="label_right"><input name="townId"  class="easyui-combobox" id="townId" type="text" style="width:174px;"/></td>
				</tr>
				<tr>
					<td align="right" class="label_left">出生年月始：</td>
					<td align="left" class="label_right"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					<td align="right" class="label_left">出生年月止：</td>
					<td align="left" class="label_right" colspan="1"><input name="endTime"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					<td align="right" class="label_left">&nbsp;</td>
					<td style="padding-left:2px">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="addPersonList()">确定</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="personinfo" title="查询条件"></table>
	</div>
  </div>
</body>
</html>