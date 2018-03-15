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
			$dg = $("#dg");
			$("#recType").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"1",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'1',codeName:"自有网点"}/* ,{codeValue:'2',codeName:"外围接入"} */],
			    onSelect:function(option){
			    	if(option.codeValue=="1"){
			    		$("#branchoo").css("display","table-row");
			    		$("#coOrgoo").css("display","none");
			    		$grid=$dg.treegrid({
							url : "sysReportQuery/sysReportQueryAction!queryBusinessRp.action?rec_Type=1",
							rownumbers:true,
							animate: true,
							collapsible: true,
							fitColumns: true,
							fit:true,
							scrollbarSize:0,
							striped:true,
							border:false,
							singleSelect:true,
							showFooter: true,
							idField: 'id',
							treeField: 'name',
							columns :[[
										{field:'id',title:'id',hidden:true},
										{field:'name',title:'网点名称',sortable:true,width:parseInt($(this).width() * 0.35)},
										{field:'num',title:'本期内笔数',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'amt',title:'本期内金额',sortable:true,width:parseInt($(this).width() * 0.1), formatter:formatAmt},
									]],
							  toolbar:'#tb',
							  loadFilter:function(data){
								    alert(data.rows);
									return data.rows;
							  },
				              onLoadSuccess:function(row,data){
				            	  $("input[type=checkbox]").each(function(){
				        				this.checked = false;
				        		  });
				            	  if($.parseJSON(data).status != 0){
				            		  $.messager.alert('系统消息',data.errMsg,'error');
				            	  }
				              }
						});
			    	}else{
			    		$("#branchoo").css("display","none");
			    		$("#coOrgoo").css("display","table-row");
			    		$grid=$dg.treegrid({
							url : "sysReportQuery/sysReportQueryAction!queryBusinessRp.action?rec_Type=2",
							fit:true,
							pagination:false,
							rownumbers:true,
							border:false,
							singleSelect:true,
							autoRowHeight:true,
							showFooter: true,
							scrollbarSize:0,
							fitColumns:true,
							animate:true,
							idField:'id',    
						    treeField:'name',
						    lines: true,
							//scrollbarSize:0,
							columns :[[
										{field:'id',title : 'id',hidden:true},
										{field:'name',title:'合作机构名称',sortable:true,width:parseInt($(this).width() * 0.35)},
										{field:'codeName',title:'交易名称',sortable:true,width:parseInt($(this).width() * 0.2)},
										{field:'num',title:'本期内笔数',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'amt',title:'本期内金额',sortable:true,width:parseInt($(this).width() * 0.1)},
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
			    	}
			    }
			});
			$("#dealCode").combobox({ 
			    url:"statistical/statisticalAnalysisAction!getAllDealCodes.action",
			    editable:false,
			    cache: false,
			    panelWidth:300,
			    groupField:"GCODE",
			    width:174,
			    showFooter:true,
			   // panelHeight: 'auto',
			    valueField:'CODE_VALUE',   
			    textField:'CODE_NAME',
			    groupFormatter:function(value){
			    	return "<span style=\"color:red;font-weight:600;font-style:italic;\">" + value + "</span>";
			    }
			});
			createSysOrg("orgId","branchId","userId");
			$grid=$dg.treegrid({
				url : "sysReportQuery/sysReportQueryAction!queryBusinessRp.action?rec_Type=1",
				rownumbers:true,
				animate: true,
				collapsible: true,
				fitColumns: true,
				fit:true,
				scrollbarSize:0,
				striped:true,
				border:false,
				singleSelect:true,
				showFooter: true,
				idField: 'id',
				treeField: 'name',
				frozenColumns:[[
						{field:'id',title :'id',hidden:true},
						{title:'网点名称',field:'name',width:parseInt($(this).width() * 0.35)},
				    ]],
				columns :[[
							{field:'num',title:'本期内笔数',width:parseInt($(this).width() * 0.1)},
							{field:'amt',title:'本期内金额',width:parseInt($(this).width() * 0.1)},
						]],
			  	toolbar:'#tb',
			  	loadFilter:function(data){
			  		$dg.treegrid('reloadFooter',data.footer);
					return data.rows;
			 	},
              	onLoadSuccess:function(row,data){
            	  	$("input[type=checkbox]").each(function(){
        				this.checked = false;
        		  	});
              	}
			});
		});
		
		function formatAmt(s, n) {
			if(isNaN(n) || n < 0 || n >= 20){
				n = 2;
			}
			
			s = parseFloat((s + "").replace(/[^\d\.-]/g, ""));
			
			if(isNaN(s)){
				s = 0;
			}
			
			s = s.toFixed(n);

			var l = (s + "").split(".")[0].split("").reverse();
			
			var r = s.split(".")[1];
			
			var t = "";
			
			for(i = 0; i < l.length; i ++ ) {  
				t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length && l[i + 1] != "-" ? "," : "");
			}
			
			return t.split("").reverse().join("") + "." + r; 
		}
		
		function query(){
			if($("#recType").combobox('getValue')=="1"){
				$dg.treegrid('load',{
					queryType:'0',//查询类型
					org_Id:$("#orgId").combobox('getValue'),
					brch_Id:$("#branchId").combobox('getValue'), 
					user_Id:$("#userId").combobox('getValue'),
					startDate:$('#beginTime').val(),
					endDate:$('#endTime').val(),
				    deal_Code:$('#dealCode').combobox('getValue')
				});
			}else if($("#recType").combobox('getValue')=="2"){
				$dg.treegrid('load',{
					queryType:'0',//查询类型
					coOrgId:$("#coOrgId").val(),
					startDate:$('#beginTime').val(),
				    endDate:$('#endTime').val(),
				    deal_Code:$('#dealCode').combobox('getValue')
				});
			}else{
				 $.messager.alert('系统消息','暂时不支持该受理点类型的统计！','error');
			}
			
		}
		function view(){
			 $.messager.alert('系统消息','此功能需要定制开发！','info');
			 return;
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
		
		function exportBusiness(){
			var params;
			if($("#recType").combobox('getValue')=="1"){
				params = {
					queryType:'0',//查询类型
					org_Id:$("#orgId").combobox('getValue'),
					brch_Id:$("#branchId").combobox('getValue'), 
					user_Id:$("#userId").combobox('getValue'),
					startDate:$('#beginTime').val(),
					endDate:$('#endTime').val(),
				    deal_Code:$('#dealCode').combobox('getValue')
				};
			}else{
				 $.messager.alert('系统消息','暂时不支持该受理点类型的统计！','error');
			}
			
			parent.$.messager.progress({
				title:"提示",
				text:"数据处理中, 请稍候..."
			});
			$.post("sysReportQuery/sysReportQueryAction!validExportBusinessRp.action", params, function(data){
				parent.$.messager.progress("close");
				if(!data || !data.status || data.status == "1" || !data.expid){
					$.messager.alert("消息提示", data.errMsg, "error");
				} else {
					$('#downloadcsv').attr('src',"sysReportQuery/sysReportQueryAction!exportBusinessRp.action?expid=" + data.expid);
				}
			}, "json");
		}
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>系统内业务</strong></span>进行查询和汇总!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				    <tr>
				       <td class="tableleft">受理点类型：</td>
				       <td class="tableright" id="org01"><input id="recType" type="text"  class="textinput easyui-validatebox" name="recType"/></td>
				       <td class="tableleft">交易代码：</td>
					   <td class="tableright"><input  id="dealCode" type="text" class="textinput" name="rec.dealCode"/></td>
					   <td class="tableleft">起始日期：</td>
					   <td class="tableright"><input id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					   <td class="tableleft">结束日期：</td>
					   <td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
				    </tr>
					<tr id="branchoo" style="display:table-row;">
						<td class="tableleft">机构编号：</td>
						<td class="tableright"><input id="orgId" type="text"  class="textinput" name="orgId"/></td>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput" name="branchId"/></td>
						<td class="tableleft">柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput" name="userId"/></td>
						<td class="tableright" colspan="2">
							<shiro:hasPermission name="voucherQuery">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="exportBusiness()">导出</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-merSettleMon'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">图形汇总</a>
							</shiro:hasPermission>
						</td>

					</tr>
					<tr id="coOrgoo" style="display:none;">
					   <td class="tableleft">合作机构编号：</td>
				       <td class="tableright"><input id="coOrgId" type="text"  class="textinput easyui-validatebox" name="coOrgId" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
				       <td class="tableleft">合作机构名称：</td>
				       <td class="tableright"><input id="coOrgName" type="text"  class="textinput easyui-validatebox" name="coOrgName" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					   <td class="tableright" colspan="4">
							<shiro:hasPermission name="voucherQuery">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="businessReport">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">导出</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="businessReport">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-merSettleMon'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">图形汇总</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="业务统计信息"></table>
	  </div>
	  <iframe id="downloadcsv" style="display: none;"></iframe>
</body>
</html>